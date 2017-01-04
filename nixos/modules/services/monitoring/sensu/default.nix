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

  client = name: address: subscriptions: {
    client = {
      inherit name address; # subscriptions;
      environment = "production";
      subscriptions = [
        "production"
      ];
      socket = {
        bind = "127.0.0.1";
        port = 3030;
      };
    };
  };

  serviceEnv = {
    LOG_LEVEL = cfg.logLevel;
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
      host = cfg.api.host;
      port = cfg.api.port;
    };
  });

  clientCfg = pkgs.writeText "client.json" (builtins.toJSON (client "app3" "127.0.0.1"));

  dashCfg = pkgs.writeText "dashboard.json" (builtins.toJSON {
    sensu = cfg.sites;
    uchiwa = cfg.dashboard // {
      loglevel = cfg.logLevel;
    };
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

      openDefaultPorts = mkOption {
        type = types.bool;
        default = false;
        description = "Automatically open the firewall ports.";
      };

      api = mkOption {
        description = "API server configuration.";
        default = {};
        type = types.submodule {
          options = {
            host = mkOption {
              type = types.str;
              default = "localhost";
              description = "The hostname of the API server.";
            };

            port = mkOption {
              type = types.int;
              default = 4567;
              description = "The port of the API server.";
            };
          };
        };
      };

      clients = mkOption {
        type = types.listOf (types.submodule (import ./sites.nix { inherit lib; }));
        default = [ ];
        description = "The clients configured.";
      };

      sites = mkOption {
        type = types.listOf (types.submodule (import ./sites.nix { inherit lib; }));
        default = [ ];
        description = "The sites configured.";
      };

      dashboard = mkOption {
        description = "The Sensu dashboard.";
        default = {};
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = (cfg.role == "server");
              description = "Enable the dashboard";
            };

            bind = mkOption {
              type = types.str;
              default = "127.0.0.1";
              description = "The interface Uchiwa will listen on.";
            };

            port = mkOption {
              type = types.int;
              default = 3000;
              description = "The port Uchiwa will listen on.";
            };

            refresh = mkOption {
              type = types.int;
              default = 5;
              description = "UI refresh interval.";
            };

            proxy = mkOption {
              type = types.bool;
              default = false;
              description = "Proxy traffic to/from the sensu dashboard.";
            };

            path = mkOption {
              type = types.str;
              default = "/";
              description = "The path to the dashboard if behind a proxy.";
            };
          };
        };
      };

      logLevel = mkOption {
        type = types.enum [ "debug" "info" "warn" "error" ];
        default = "info";
        description = "The level of logging.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      # sensu-plugins
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openDefaultPorts [
      # cfg.api.port
      cfg.dashboard.port
    ];

    users.extraGroups.sensu.gid = config.ids.gids.sensu;

    users.extraUsers.sensu = {
      description = "Sensu daemon user";
      uid = config.ids.uids.sensu;
      group = "sensu";
    };

    services = {
      nginx = lib.mkIf cfg.dashboard.proxy {
        enable = true;
        virtualHosts = {
          "www.${cfg.domain}somedomain.com" = {
            extraConfig = let
              rewrite = cfg.dashboard.proxy;
              path = cfg.dashboard.path;
            in ''
              location ~ ${if rewrite then "(${path}/|/socket.io/)" else "/"} {
                proxy_pass http://localhost:${cfg.dashboard.port};
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host $host;

                ${lib.optionalString rewrite "rewrite /uchiwa/(.*) /$1 break;"}
              }
            '';
          };
        };
      };
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
          environment = serviceEnv;
          serviceConfig = serviceCfg // {
            ExecStart = bin "server";
          };
        };

        sensu-api = lib.mkIf (cfg.role == "server") {
          description = "Sensu API Server";
          wantedBy = defaultTarget;
          environment = serviceEnv;
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
          # path = [ pkgs.sensu-plugins ];
          environment = serviceEnv;
          serviceConfig = serviceCfg // {
            ExecStart = bin "client";
          };
        };
      };
    };
  };
}
