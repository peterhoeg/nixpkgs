{ config, lib, pkgs, ... }:

let
  cfg = config.networking.firewalld;

  inherit (lib)
    mkEnableOption mkIf mkOption types;

in
{
  options.networking.firewalld = {
    enable = mkEnableOption ''
      firewalld. firewalld is a high-level Linux-based packet
      filtering framework intended for desktop use cases.

      This conflicts with the standard networking firewall, so make sure to
      disable it before using firewalld.
    '';
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.networking.firewall.enable == false;
      message = "You can not use firewalld with services.networking.firewall.";
    }];

    environment.etc.firewalld.source = "${pkgs.firewalld}/etc/firewalld";

    services = {
      dbus.packages = with pkgs; [ firewalld ];
    };

    systemd = {
      packages = with pkgs; [ firewalld ];

      services.firewalld = {
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
