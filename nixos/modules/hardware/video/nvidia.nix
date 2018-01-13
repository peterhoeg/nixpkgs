# This module provides the proprietary NVIDIA X11 / OpenGL drivers.

{ config, lib, pkgs, pkgs_i686, ... }:

with lib;

let
  drivers = config.services.xserver.videoDrivers;

  cfg = config.hardware.video.nvidia;

  # FIXME: should introduce an option like
  # ‘hardware.video.nvidia.package’ for overriding the default NVIDIA
  # driver.
  nvidiaForKernel = kernelPackages:
    if elem "nvidia" drivers then
        kernelPackages.nvidia_x11
    else if elem "nvidiaBeta" drivers then
        kernelPackages.nvidia_x11_beta
    else if elem "nvidiaLegacy173" drivers then
      kernelPackages.nvidia_x11_legacy173
    else if elem "nvidiaLegacy304" drivers then
      kernelPackages.nvidia_x11_legacy304
    else if elem "nvidiaLegacy340" drivers then
      kernelPackages.nvidia_x11_legacy340
    else null;

  nvidia_x11 = nvidiaForKernel config.boot.kernelPackages;
  nvidia_libs32 = (nvidiaForKernel pkgs_i686.linuxPackages).override { libsOnly = true; kernel = null; };

  nvidiaPackage = nvidia: pkgs:
    if !nvidia.useGLVND then nvidia.out
    else pkgs.buildEnv {
      name = "nvidia-libs";
      paths = [ pkgs.libglvnd nvidia.out ];
    };

  enableNvidia = nvidia_x11 != null;

  boolToStr = bool:
    lib.toString (if bool then 1 else 0);

in {

  options.hardware.video.nvidia = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enable suppor for nVidia video hardware
      '';
    };

    preferNouveau = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Prefer the Open Source nouveau driver instead of the propriatary nvidia driver.
      '';
    };

    atomic = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Expose atomic ioctl

        NOTE: This only applies to the  `nouveau` driver.
      '';
    };

    boostMode = mkOption {
      default = 0;
      type = types.enum [ 0 1 2 ];
      description = ''
        Enable re-clocking/boost mode.

        0 = disable
        1 = enable (conservative)
        2 = enable (aggressive)

        In order to get decent performance, you will enable to enable this at least at the conservative level. It may however, cause problems on some setups which is why it is disabled by default.

        NOTE: This only applies to the  `nouveau` driver.
      '';
    };

    externalFirmware = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Load the binary nvidia firmware with the nouveau driver.

        NOTE: This only applies to the  `nouveau` driver.
      '';
    };

    xDriver = mkOption {
      default = "modesetting";
      type = types.enum [ "modesetting" "nouveau" ];
      description = ''
        The driver to use for X.
      '';
    };
  };

  config = lib.mkIf (enableNvidia || cfg.preferNouveau) {
    assertions = lib.mkIf enableNvidia [
      {
        assertion = config.services.xserver.displayManager.gdm.wayland;
        message = "NVidia drivers don't support wayland";
      }
    ];

    boot = {
      blacklistedKernelModules = if cfg.preferNouveau then [ "nvidia" ] else [ "nouveau" "nvidiafb" ];

      extraModulePackages = lib.optional (!cfg.preferNouveau) nvidia_x11.bin;

      extraModprobeConfig = lib.mkIf cfg.preferNouveau ''
        options nouveau atomic=${boolToStr cfg.atomic} modeset=1 config=NvGrUseFw=${boolToStr cfg.externalFirmware},NvBoost=${toString cfg.boostMode}
      '';

      kernelModules = if (cfg.preferNouveau && config.services.xserver.enable)
        then [ "nouveau"]
        # nvidia-uvm is required by CUDA applications.
        else [ "nvidia-uvm" ] ++
          lib.optionals config.services.xserver.enable [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
    };

    environment = {
      etc."nvidia/nvidia-application-profiles-rc" = mkIf (!cfg.preferNouveau && nvidia_x11.useProfiles) {
        source = "${nvidia_x11.bin}/share/nvidia/nvidia-application-profiles-rc";
      };

      systemPackages = mkIf (!cfg.preferNouveau) [ nvidia_x11.bin nvidia_x11.settings ]
        ++ lib.filter (p: p != null) [ nvidia_x11.persistenced ];
    };

    hardware = {
      firmware = lib.mkIf (cfg.preferNouveau && cfg.externalFirmware) [ pkgs.firmwareLinuxNvidia ];

      opengl.package   = lib.mkIf (!cfg.preferNouveau) nvidiaPackage nvidia_x11 pkgs;
      opengl.package32 = lib.mkIf (!cfg.preferNouveau) nvidiaPackage nvidia_libs32 pkgs_i686;
    };

    services = {
      acpid.enable = true;

      # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
      udev.extraRules = lib.mkIf (!cfg.preferNouveau) ''
        KERNEL=="nvidia", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidiactl c $(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 255'"
        KERNEL=="nvidia_modeset", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia-modeset c $(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 254'"
        KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="nvidia", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia%n c $(grep nvidia-frontend /proc/devices | cut -d \  -f 1) %n'"
        KERNEL=="nvidia_uvm", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia-uvm c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
      '';

      xserver = {
        drivers = mkIf (!cfg.preferNouveau) singleton
          { name = "nvidia"; modules = [ nvidia_x11.bin ]; libPath = [ nvidia_x11 ]; };

        screenSection = mkIf (!cfg.preferNouveau) ''
          Option "RandRRotation" "on"
        '';

        # videoDrivers = optional cfg.preferNouveau cfg.xDriver;
      };
    };
  };
}
