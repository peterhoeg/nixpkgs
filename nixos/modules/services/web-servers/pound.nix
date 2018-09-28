{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pound;
  runDir = "/run/pound";
  configFile = pkgs.writeText "pound.cfg" ''
    # As we run with DynamicUser = true, the permissions on the socket means
    # that we cannot control this instance with poundctl anyway
    # Control "${runDir}/pound.sock"
    Daemon 0

    ${cfg.config}
  '';

in {
  options.services.pound = {
    enable = mkEnableOption "Pound reverse proxy";

    config = mkOption {
      default = "";
      type = types.lines;
      description = "Verbatim pound.cfg to use";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pound = {
      description = "Pound reverse proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = "${pkgs.pound}/bin/pound -f ${configFile} -c";
        ExecStart    = "${pkgs.pound}/bin/pound -f ${configFile} -p ${runDir}/pound.pid";
        Restart = "on-failure";
        RuntimeDirectory = builtins.baseNameOf runDir;
        DynamicUser = true;
        NoNewPrivileges = true;
        AmbientCapabilities = "cap_net_bind_service";
      };
    };
  };
}
