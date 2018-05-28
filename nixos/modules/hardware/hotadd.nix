{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.hardware.hotadd;

  order = 90;

  cpu = pkgs.writeTextFile {
    name = "cpu-hotadd-udev-rules";
    destination = "/lib/udev/rules.d/${toString order}-cpu-hotadd.rules";
    text = ''
      SUBSYSTEM=="cpu", ACTION=="add", TEST=="online", ATTR{online}=="0", ATTR{online}="1"
    '';
  };

  mem = pkgs.writeTextFile {
    name = "memory-hotadd-udev-rules";
    destination = "/lib/udev/rules.d/${toString order}-memory-hotadd.rules";
    text = ''
      SUBSYSTEM=="memory", ACTION=="add", TEST=="state", ATTR{state}=="offline", ATTR{state}="online"
    '';
  };

in {
  options.hardware.hotadd = {
    cpu = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables udev rules for hot-adding CPUs.
      '';
    };

    memory = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables udev rules for hot-adding memory.
      '';
    };
  };

  config = {
    services.udev.packages = []
    ++ lib.mkIf cfg.cpu    cpu
    ++ lib.mkIf cfg.memory mem;
  };
}
