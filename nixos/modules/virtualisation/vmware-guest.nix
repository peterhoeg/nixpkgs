{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.virtualisation.vmware.guest;
  open-vm-tools = if cfg.headless then pkgs.open-vm-tools-headless else pkgs.open-vm-tools;
  xf86inputvmmouse = pkgs.xorg.xf86inputvmmouse;
  cfgFmt = pkgs.formats.ini { };

in
{
  imports = [
    (mkRenamedOptionModule [ "services" "vmwareGuest" ] [ "virtualisation" "vmware" "guest" ])
  ];

  options.virtualisation.vmware.guest = {
    enable = mkEnableOption "VMWare Guest Support";

    headless = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to disable X11-related features.";
    };

    settings = mkOption {
      type = cfmFmt.type;
      default = { };
      description = "Settings passed through to tools.conf";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = pkgs.stdenv.isi686 || pkgs.stdenv.isx86_64;
      message = "VMWare guest is not currently supported on ${pkgs.stdenv.hostPlatform.system}";
    }];

    boot.initrd.kernelModules = [ "vmw_pvscsi" ];

    environment.systemPackages = [ open-vm-tools ];

    systemd.services.vmware = {
      description = "VMWare Guest Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${open-vm-tools}/bin/vmtoolsd -c /etc/vmware-tools";
        PrivateTmp = true;
        ProtectHome = "tmpfs";
        ProtectSystem = "strict";
      };
    };

    environment.etc.vmware-tools."tools.conf".source = cfgFmt.generate "tools.conf"
      (lib.recursiveUpdate
        {
          guestosinfo = {
            short-name = "NixOS";
          };

          logging = lib.mapListToAttrs (map
            (e:
              lib.nameValuePair "${e}.handler" "std") [ "vmtoolsd" "vmsvc" "vmresset" "vmusr" "toolboxcmd" "hgfsServer" "hgfsd" "vmbackup" "vmvss" ]);

          powerops = {
            poweron-script = "${open-vm-tools}/libexec/poweron-vm-default";
            poweroff-script = "${open-vm-tools}/libexec/poweroff-vm-default";
            resume-script = "${open-vm-tools}/libexec/resume-vm-default";
            suspend-script = "${open-vm-tools}/libexec/suspend-vm-default";
          };
        }
        cfg.settings);

    services.xserver = mkIf (!cfg.headless) {
      videoDrivers = mkOverride 50 [ "vmware" ];
      modules = [ xf86inputvmmouse ];

      config = ''
        Section "InputClass"
          Identifier "VMMouse"
          MatchDevicePath "/dev/input/event*"
          MatchProduct "ImPS/2 Generic Wheel Mouse"
          Driver "vmmouse"
        EndSection
      '';

      displayManager.sessionCommands = ''
        ${open-vm-tools}/bin/vmware-user-suid-wrapper
      '';
    };
  };
}
