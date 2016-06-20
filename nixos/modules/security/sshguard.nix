{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    services.sshguard = {
      enable = mkEnableOption "Enable automatic blocking of attack attemps.";
    };
  };

  config = mkIf config.services.sshguard.enable {

    security.polkit.enable = true;

    # To make polkit pickup rtkit policies
    environment.systemPackages = [ pkgs.rtkit ];

    systemd.packages = [ pkgs.rtkit ];

    services.dbus.packages = [ pkgs.rtkit ];

    users.extraUsers = singleton
      { name = "rtkit";
        uid = config.ids.uids.rtkit;
        description = "RealtimeKit daemon";
      };

  };

}
