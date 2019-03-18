{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.smart;

  smartDeviceOpts = { name, ... }: {
    options = {

      device = mkOption {
        example = "/dev/sda";
        type = types.str;
        description = "Location of the device.";
      };

      timeout = mkOption {
        default = -1;
        example = "70";
        type = types.int;
        description = ''
          Set SCT Error Recovery Control timeout in deciseconds for use in RAID configurations.
          Values are as follows:
            -1 = do not touch, leave at default
             0 = disable SCT ERT
            70 = default in consumer drives (7 seconds)
          Maximum is disk dependant but probably 60 seconds.
        '';
      };

      options = mkOption {
        default = "";
        example = "-J 30";
        type = types.separatedString " ";
        description = "Options for smartctl";
      };
    };
  };

  deviceTimeout = d:
    lib.optionalString (d.timeout > -1) ''
      ${smartctl} ${d.device} "-l scterc,${d.timeout},${d.timeout} --silent errorsonly"
    '';

  smartctl = device: options: ''
    ${pkgs.smartmontools}/bin/smartctl ${options} ${device}
  '';

in {
  options.hardware.smart = {
    enable = mkEnableOption "SMART for disks";

    devices = mkOption {
      default = [];
      example = [
        { device = "/dev/sda"; timeout = 0; }
        { device = "/dev/sdb"; options = "-J 30"; } ];
      type = with types; listOf (submodule smartDeviceOpts);
      description = "List of devices for which to configure SMART settings";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.smart = {
      description = "Configure SMART for storage devices";
      before = [ "smartd.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${concatMapStringsSep "\n" deviceTimeout cfg.devices}
        # ${concatMapStringsSep "\n" deviceTimeout cfg.devices}
      '';
      serviceConfig = {
        Type = "oneshot";
        PrivateTmp = true;
        PrivateNetwork = true;
      };
    };
  };
}
