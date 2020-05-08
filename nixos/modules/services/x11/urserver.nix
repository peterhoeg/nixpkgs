# urserver service
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.urserver;
in {

  options.services.urserver = {

    enable = mkEnableOption "urserver";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open ports in the firewall to interact with the urserver.
      '';
    };

    usedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ 9510 9512 ];
      description = ''
        TCP ports that are used by urserver.
        By default port 9510 is used for the web server.
        By default port 9512 is used for WiFi connections.
      '';
    };

    usedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ 9511 9512 ];
      description = ''
        UDP ports that are used by urserver.
        By default port 9511 is used for automatic server discovery.
        By default port 9512 is used for fast connections.
      '';
    };

  };

  config = mkIf cfg.enable {
    systemd.user.services.urserver =  {
      description = ''
        Server for Unified Remote: The one-and-only remote for your computer.
      '';
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = ''
          ${pkgs.urserver}/bin/urserver --daemon
        '';
        ExecStop = ''
          ${pkgs.procps}/bin/pkill urserver
        '';
        RestartSec = 3;
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = cfg.usedTCPPorts;
      allowedUDPPorts = cfg.usedUDPPorts;
    };

  };

}
