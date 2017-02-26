{ config, pkgs, lib, ... }:

let
  cfg = config.services.sensu;
  pgm = cfg.programs;

  baseDir = "/etc/sensu";

  bin = binary:
  "${cfg.package}/bin/sensu-${binary} -c ${baseDir}/config.json -d ${baseDir}/conf.d";

  sensuService = desc: bin: sCfg: {
    description = "Sensu ${desc}";
    wantedBy    = [ "sensu.target" ];
    path        = cfg.dependencies ++ [
      cfg.package
      "/run/current-system/sw"
      "/run/wrappers"
    ]
    ++ lib.optionals pgm.ipmi [ pkgs.ipmitool ]
    ++ lib.optionals pgm.snmp [ pkgs.snmp ]
    ;
    environment = {
      LOG_LEVEL = cfg.logLevel;
    };
    restartTriggers = [ sCfg checkCfg ];
    serviceConfig = {
      ExecStart     = bin;
      DynamicUser   = true;
      Slice         = "sensu.slice";
      Restart       = "on-failure";
      RestartSec    = "2s";
      ProtectSystem = "strict";
      ProtectHome   = true;
      PrivateTmp    = true;
    };
  };

  cleanAttrSet = set:
    lib.filterAttrsRecursive (k: v: !(k == "_module" || v == "")) set;

  checkCfg = pkgs.writeText "checks.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) checks;
  }));

  sensuCfg = pkgs.writeText "config.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) api redis transport;
  }));

  clientCfg = pkgs.writeText "client.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) client;
  }));

  dashCfg = pkgs.writeText "uchiwa.json" (builtins.toJSON (cleanAttrSet {
    # cfg.sites is a listOf attrset, so we need to loop over them
    sensu = (map (e: (cleanAttrSet e)) cfg.sites);
    uchiwa = cfg.dashboard // {
      loglevel = cfg.logLevel;
    };
  }));

in {

  options = {
    services.sensu = with lib; with types; {
      enable = mkOption {
        type = bool;
        default = false;
        description = ''
          Enable the Sensu network monitoring daemon.
        '';
      };

      role = mkOption {
        type = enum [ "server" "client" ];
        default = "server";
        description = "Operate as client only or server and client.";
      };

      transport = mkOption {
        default = {};
        description = "The transport.";
        type = submodule {
          options = {
            name = mkOption {
              type = enum [ "redis" "rabbitmq" ];
              default = "redis";
              description = "The transport to use.";
            };

            reconnect_on_error = mkOption {
              type = bool;
              default = true;
              description = "Automatically reconnect on error.";
            };
          };
        };
      };

      openDefaultPorts = mkOption {
        type = bool;
        default = false;
        description = "Automatically open the firewall ports.";
      };

      package = mkOption {
        type = package;
        default = pkgs.sensu;
        description = "The package to use.";
      };

      dependencies = mkOption {
        type = listOf package;
        default = [];
        description = "Additional packages to inject into the path.";
      };

      logLevel = mkOption {
        type = enum [ "debug" "info" "warn" "error" ];
        default = "info";
        description = "The level of logging.";
      };

      redis = mkOption {
        description = "Redis configuration.";
        default = {};
        type = submodule {
          options = {
            host = mkOption {
              type = str;
              default = "127.0.0.1";
              description = "The hostname of the redis server.";
            };

            port = mkOption {
              type = int;
              default = 6379;
              description = "The port of the redis server.";
            };
          };
        };
      };

      api = mkOption {
        description = "API server configuration.";
        default = {};
        type = submodule {
          options = {
            host = mkOption {
              type = str;
              default = "localhost";
              description = "The hostname of the API server.";
            };

            port = mkOption {
              type = int;
              default = 4567;
              description = "The port of the API server.";
            };
          };
        };
      };

      programs = let
        programOption = name: mkOption {
          type = bool;
          default = false;
          description = "Enable support for ${name}.";
        }; in mkOption {
        description = "Programs to enable for checks";
        default = {};
        type = submodule {
          options = {
            ipmi = programOption "ipmi";
            snmp = programOption "snmp";
          };
        };
      };

      checks = mkOption {
        type = with types; attrsOf (submodule (import ./checks.nix { inherit lib; }));
        default = [ ];
        description = "The checks configured.";
      };

      client = mkOption {
        description = "The client configuration.";
        default = {};
        type = submodule (import ./client.nix { inherit lib; });
      };

      dashboard = mkOption {
        description = "The Sensu dashboard.";
        default = {};
        type = submodule (import ./dashboard.nix { inherit cfg lib; });
      };

      sites = mkOption {
        type = listOf (submodule (import ./sites.nix { inherit lib; }));
        default = [ ];
        description = "The sites configured.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment = let dir = "${lib.removePrefix "/etc/" baseDir}/conf.d"; in {
      etc = {
        client = {
          source = clientCfg;
          target = "${dir}/client.json";
        };
        config = {
          source = sensuCfg;
          target = "sensu/config.json";
        };
        dash = {
          source = dashCfg;
          target = "sensu/uchiwa.json";
        };
        checks = {
          source = checkCfg;
          target = "${dir}/checks.json";
        };
      };

      systemPackages = with pkgs; [
        jq
        tree
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openDefaultPorts [
      (if cfg.role == "server" then cfg.api.port       else "")
      (if cfg.dashboard.enable then cfg.dashboard.port else "")
    ];

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
        sensu-api       = lib.mkIf (cfg.role == "server") (sensuService "API"       (bin "api")    sensuCfg);
        sensu-client    =                                 (sensuService "Client"    (bin "client") clientCfg);
        sensu-server    = lib.mkIf (cfg.role == "server") (sensuService "Server"    (bin "server") sensuCfg);
        sensu-dashboard = lib.mkIf cfg.dashboard.enable   (sensuService "Dashboard"
          "${pkgs.uchiwa}/bin/uchiwa -c ${baseDir}/uchiwa.json"
          dashCfg
        );
      };

      targets.sensu = {
        description = "Sensu Monitoring";
        wantedBy    = [ "multi-user.target" ];
      };
    };
  };
}
