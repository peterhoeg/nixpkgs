{ config, pkgs, lib, ... }:

let

  cfg = config.services.sensu;

  configDir = pkgs.stdenv.mkDerivation {
    name = "sensu-config";
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/conf.d
      ln -s ${sensuCfg}  $out/config.json
      ln -s ${dashCfg}   $out/dashboard.json
      ln -s ${clientCfg} $out/conf.d/client.json
    '';
  };

  bin = binary:
  "${pkgs.sensu}/bin/sensu-${binary} -c ${configDir}/config.json -d ${configDir}/conf.d";

  serviceCfg = {
    User = "sensu";
    Group = "sensu";
    Slice = "sensu.slice";
    ProtectSystem = "full";
    ProtectHome = true;
    PrivateTmp = true;
    Restart = "on-failure";
  };

  sensuCfg = pkgs.writeText "config.json" (builtins.toJSON {
    redis = {
      host = "127.0.0.1";
      port = 6379;
    };
    transport = {
      name = cfg.transport;
      reconnect_on_error = true;
    };
    api = {
      host = "127.0.0.1";
      port = 4567;
    };
  });

  clientCfg = pkgs.writeText "client.json" (builtins.toJSON {
    client = {
      name = "client-01";
      address = "127.0.0.1";
      environment = "production";
      subscriptions = [
        "production"
      ];
      socket = {
        bind = "127.0.0.1";
        port = 3030;
      };
    };
  });

  dashCfg = pkgs.writeText "dashboard.json" (builtins.toJSON {
    sensu = cfg.sites;
    uchiwa = cfg.dashboard;
  });

  defaultTarget = [ "multi-user.target" ];

in {

  options = {
    services.sensu = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable the Sensu network monitoring daemon.
        '';
      };

      role = mkOption {
        type = types.enum [ "server" "client" ];
        default = "server";
        description = "Operate as server or client.";
      };

      transport = mkOption {
        type = types.enum [ "redis" "rabbitmq" ];
        default = "redis";
        description = "The transport to use.";
      };

      sites = mkOption {
        type = types.listOf (types.submodule (import ./sites.nix { inherit lib; }));
        default = [ ];
        description = "efef";
      };

      dashboard = mkOption {
        type = types.attrsOf (types.submodule (import ./dashboard.nix { inherit lib; }));
        default = { };
        description = "efef";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      sensu-plugins
    ];

    networking.firewall.allowedTCPPorts = [ ];

    users.extraGroups.sensu.gid = config.ids.gids.sensu;

    users.extraUsers.sensu = {
      description = "Sensu daemon user";
      uid = config.ids.uids.sensu;
      group = "sensu";
    };

    services = {
      rabbitmq = lib.mkIf (cfg.transport == "rabbitmq") {
        enable = true;
      };

      redis = {
        enable = true;
        bind = "127.0.0.1";
      };
    };

    systemd = {
      services = {
        sensu-server = lib.mkIf (cfg.role == "server") {
          description = "Sensu Server";
          wantedBy = defaultTarget;
          serviceConfig = serviceCfg // {
            ExecStart = bin "server";
          };
        };

        sensu-api = lib.mkIf (cfg.role == "server") {
          description = "Sensu API Server";
          wantedBy = defaultTarget;
          serviceConfig = serviceCfg // {
            ExecStart = bin "api";
          };
        };

        sensu-dashboard = lib.mkIf (cfg.role == "server") {
          description = "Sensu Dashboard";
          wantedBy = defaultTarget;
          serviceConfig = serviceCfg // {
            ExecStart = "${pkgs.uchiwa}/bin/uchiwa -c ${configDir}/dashboard.json";
          };
        };

        sensu-client =  {
          description = "Sensu Client";
          wantedBy = defaultTarget;
          path = [ pkgs.sensu-plugins ];
          serviceConfig = serviceCfg // {
            ExecStart = bin "client";
          };
        };
      };
    };
  };
}
