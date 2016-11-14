{ config, lib, pkgs, ... }:

with lib;

{
  ###### interface

  options = {

    hardware.usb_wwan = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable this option to support USB WWAN adapters.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf config.hardware.usb_wwan.enable {
    services.udev.packages = with pkgs; [ usb-modeswitch-data ];
  };
}
