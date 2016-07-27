{ config, lib, pkgs, ... }:

with lib;

{
  ###### interface

  options = {
    hardware.sensor.iio = {
      enable = mkEnableOption "Enable this option to support IIO sensors.";
    };
  };

  ###### implementation

  config = mkIf config.hardware.sensor.iio.enable {

    boot.initrd.availableKernelModules = [ "hid-sensor-hub" ];

    services.dbus.packages = [ pkgs.iio-sensor-proxy ];
    services.udev.packages = [ pkgs.iio-sensor-proxy ];
    systemd.packages = [ pkgs.iio-sensor-proxy ];

    systemd.services.iio-sensor-proxy.wantedBy = [ "multi-user.target" ];
  };
}
