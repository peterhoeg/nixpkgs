{ config, pkgs, lib, ... }:

let
  cfg = config.services.sensu;
  pgm = cfg.programs;

  baseDir = "/etc/sensu";

  transportIsRabbitMQ = (cfg.transport.name == "rabbitmq");
  roleIsClient = lib.elem "client" cfg.role;
  roleIsServer = lib.elem "server" cfg.role;

  # Setting the LOG_LEVEL env var doesn't work, so we force the logLevel via -L
  bin = binary: lib.concatStringsSep " " [
    "${cfg.package}/bin/sensu-${binary}"
    "-c ${baseDir}/config.json"
    "-d ${baseDir}/conf.d"
    "-e ${baseDir}/extensions"
    "-L ${cfg.logLevel}"
  ];

  sensuService = desc: bin:
  let
    pgm = lib.toLower desc;
    isClient = lib.elem pgm [ "client" ];
    isDash   = lib.elem pgm [ "dashboard" ];
    isServer = lib.elem pgm [ "api" "server" ];
  in {
    description = "Sensu ${desc}";
    wantedBy    = [ "sensu.target" ];
    after       = []
      ++ lib.optionals isServer [ "redis.service" "rabbmitmq.service" ];
    # 1. Sensu is very shell-happy. I don't know if it actually requires bash
    # per se, but it definitely needs a shell.
    # 2. We need /run/wrappers early so the wrapped binary is found first
    path = [
      "/run/wrappers" pkgs.bash cfg.client.execEnv
    ] ++ lib.optional isServer cfg.server.execEnv;

    # Needed for bundler
    environment.HOME = "/tmp";

    restartTriggers = [ ]
      ++ lib.optionals isClient [ sensuCfg clientCfg ]
      ++ lib.optionals isDash   [ dashCfg ]
      ++ lib.optionals isServer [ sensuCfg checkCfg filterCfg handlerCfg tessenCfg ];

    preStart = lib.optionalString isClient ''
      dir=/run/sensu

      ${lib.optionalString (cfg.client.execEnv != null) ''
        rm -rf $dir/bin
        ln -s ${cfg.client.execEnv}/bin $dir/bin
      ''}

      ${lib.optionalString (cfg.client.wrapper != null) ''
        rm -rf $dir/libexec
        mkdir -p $dir/libexec
        ln -s ${cfg.client.wrapper} $dir/libexec/wrapper.sh
      ''}
    '';

    serviceConfig = {
      ExecStart        = bin;
      # ping fails with DynamicUser = true
      DynamicUser      = false;
      User             = "sensu";
      Group            = "sensu";
      Slice            = "sensu.slice";
      Restart          = "on-failure";
      # Upstream recommends 1m which seems VERY long
      RestartSec       = "10s";
      ProtectSystem    = "full";
      # ProtectControlGroups = true;
      # ProtectKernelTunables = true;
      # ProtectKernelModules = true;
      # SystemCallArchitectures = "native";

      # Sensu expects a common file in $HOME which must be shared with the other
      # sensu units this can be enabled when our systemd module gets support for
      # JoinsNamespaceOf.
      PrivateTmp       = true;
      TimeoutStopSec   = "5s";
      StateDirectory = "sensu";
      RuntimeDirectory = lib.mkIf isClient "sensu";
      SupplementaryGroups = lib.mkIf isClient "systemd-journal";
      # NoNewPrivileges = true;
    };
  };

  # This function serves two purposes:
  #
  # 1) We do a lot of attrs -> json but nix will add a "_module" key when
  #    dumping a submodule which is at best noise and in the worst case causes
  #    an unexpected setting to be set
  #
  # 2) We do not want to set defaults for everything (as defaults change), so if
  #    a value is an empty string|list|set, we simply remove the key from the
  #    generated JSON to allow sensu to apply its own defaults

  cleanAttrSet = set_or_list:
    if builtins.isList set_or_list
      then (map (s: cleanAttrSet s) set_or_list)
      else lib.filterAttrsRecursive (k: v:
            !(k == "_module" || v == "" || v == [] || v == {})) set_or_list;

  checkCfg = pkgs.writeText "checks.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) checks;
  }));

  filterCfg = pkgs.writeText "filters.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) filters;
  }));

  handlerCfg = pkgs.writeText "handlers.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) handlers;
  } // cfg.plugins));

  mutatorCfg = pkgs.writeText "mutators.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) mutators;
  }));

  sensuCfg = let
    rabbitmq = cleanAttrSet cfg.rabbitmq;
  in pkgs.writeText "config.json" (builtins.toJSON ({
    inherit rabbitmq;
  } // (cleanAttrSet (if roleIsServer
    then { inherit (cfg) api extensions influxdb mutators redis transport; } // cfg.extraServerConfig
    else { inherit (cfg)     extensions                         transport; } // cfg.extraClientConfig))));

  clientCfg = pkgs.writeText "client.json" (builtins.toJSON (cleanAttrSet {
    inherit (cfg) client;
  }));

  dashCfg = pkgs.writeText "uchiwa.json" (builtins.toJSON (cleanAttrSet {
    sensu = cleanAttrSet cfg.sites;
    uchiwa = cfg.dashboard // {
      loglevel = cfg.logLevel;
    };
  }));

  # disabled by default but we want to make sure
  tessenCfg = pkgs.writeText "tessen.json" (builtins.toJSON {
    enabled = false;
  });

  # Currently not used
  makePlugin = name: config: base:
    let
      fileName = "plugin-${name}.json";
    in {
      source = pkgs.writeText fileName (builtins.toJSON { "${name}" = config; });
      target = "${base}/${fileName}";
    };

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

      # Add support for dashboard rabbitmq redis etc
      role = mkOption {
        # type = listOf (enum [ "server" "client" "dashboard" "influxdb" "rabbmitmq" "redis" ]);
        type = listOf (enum [ "server" "client" ]);
        default = [ "server" ];
        description = "Run one or more of: server, client, dashboard, influxdb, rabbitmq and redis.";
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

      defaultClientSubscriptions = mkOption {
        type = listOf str;
        default = [ "sensu-client" ];
        description = "Default subscriptions for sensu clients.";
      };

      defaultServerSubscriptions = mkOption {
        type = listOf str;
        default = [ "sensu-server" ];
        description = "Default subscriptions for sensu servers.";
      };

      defaultSubscriptions = {
        enable = mkEnableOption "Default checks of the sensu environment.";

        interval = mkOption {
          description = "How frequently to run interval checks.";
          default = 60;
          type = int;
        };

        occurrences = mkOption {
          description = "How many occurrences before we trigger an alert.";
          default = 2;
          type = int;
        };
      };

      package = mkOption {
        type = package;
        default = pkgs.sensu;
        description = "The package to use.";
      };

      server.execEnv = mkOption {
        type = package;
        description = "The execution environment for all checks";
      };

      logLevel = mkOption {
        type = enum [ "debug" "info" "warn" "error" "fatal" ];
        default = "info";
        description = ''The level of logging. The default info is VERY verbose
          and you probably want to change this to 'warn' when things are working
        '';
      };

      extraClientConfig = mkOption {
        type = attrs;
        default = {};
        description = "Additional configuration data that will be added to the client config.";
      };

      extraServerConfig = mkOption {
        type = attrs;
        default = {};
        description = "Additional configuration data that will be added to the server config.";
      };

      extensions = mkOption {
        type = attrs;
        default = {};
        description = "Extensions to load.";
      };

      redis = mkOption {
        description = "Redis configuration.";
        default = {};
        type = (submodule (import ./host_port_pair.nix {
          inherit lib;
          name = "redis";
          defaultHost = "127.0.0.1";
          defaultPort = 6379;
        }));
      };

      influxdb = mkOption {
        description = "InfluxDB configuration.";
        default = {};
        type = (submodule (import ./host_port_pair.nix {
            inherit lib;
            name = "influxdb";
            defaultHost = "localhost";
            defaultPort = 8086;
            options = {
              database = mkOption {
                default = "sensu";
                description = "InfluxDB database";
                type = str;
              };

              user = mkOption {
                default = null;
                description = "InfluxDB user";
                type = nullOr str;
              };

              password = mkOption {
                default = null;
                description = "InfluxDB password";
                type = nullOr str;
              };

              templates = mkOption {
                default = {};
                description = "Templates";
                type = attrs;
              };
            };
        }));
      };

      rabbitmq = mkOption {
        description = "RabbitMQ configuration.";
        default = [];
        type = listOf (submodule (import ./host_port_pair.nix {
            inherit lib;
            name = "rabbitmq";
            defaultHost = "127.0.0.1";
            defaultPort = config.services.rabbitmq.port;
            options = {
              vhost = mkOption {
                default = "/sensu";
                description = "RabbitMQ vhost";
                type = str;
              };

              user = mkOption {
                default = "sensu";
                description = "RabbitMQ user";
                type = str;
              };

              password = mkOption {
                description = "RabbitMQ password";
                type = str;
              };

              heartbeat = mkOption {
                default = 30;
                description = "RabbitMQ heartbeat";
                type = int;
              };

              prefetch = mkOption {
                default = 50;
                description = "RabbitMQ prefetch";
                type = int;
              };

              ssl = mkOption {
                default = {};
                description = "RabbitMQ SSL options.";
                type = submodule {
                  options = {
                    cert_chain_file = mkOption {
                      default = "";
                      description = "Path to the cert chain file.";
                      type = str;
                    };

                    private_key_file = mkOption {
                      default = "";
                      description = "Path to the private key file.";
                      type = str;
                    };
                  };
                };
              };
            };
        }));
      };

      configureInfluxDb = mkOption {
        default = false;
        description = "Whether the database should be configured for Sensu on InfluxDB.";
        type = bool;
      };

      configureRabbitMq = mkOption {
        default = false;
        description = "Whether the vhost/user/permissions should be configured for Sensu on RabbitMQ.";
        type = bool;
      };

      api = mkOption {
        description = "API server configuration.";
        default = {};
        type = (submodule (import ./host_port_pair.nix {
          inherit lib;
          name = "api";
          defaultHost = "127.0.0.1";
          defaultPort = 4567;
          options = {
            bind = mkOption {
              type = str;
              default = "0.0.0.0";
              description = "The address that the API will bind to (listen on).";
            };
          };
        }));
      };

      programs = let
        programOption = name: default: mkOption {
          type = bool;
          description = "Enable support for ${name}.";
          inherit default;
        }; in mkOption {
        description = "Programs to enable for checks";
        default = {};
        type = submodule {
          options = {
            # some of the built-in checks require the common package
            common  = programOption "common"  true;
            esx     = programOption "esx"     false;
            http    = programOption "http"    false;
            ipmi    = programOption "ipmi"    false;
            network = programOption "network" false;
            openvpn = programOption "openvpn" false;
            snmp    = programOption "snmp"    false;
            ups     = programOption "ups"     false;
            windows = programOption "windows" false;
          };
        };
      };

      checks = mkOption {
        type = with types; attrsOf (submodule (import ./checks.nix { inherit lib; }));
        default = {};
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
        type = submodule (import ./dashboard.nix { inherit cfg config lib; });
      };

      filters = mkOption {
        type = attrs;
        default = {};
        description = "The filters available to Sensu.";
      };

      handlers = mkOption {
        type = with types; attrsOf (submodule (import ./handlers.nix { inherit lib; }));
        default = {};
        description = "The handlers available to Sensu.";
      };

      mutators = mkOption {
        type = with types; attrsOf (submodule (import ./mutators.nix { inherit lib; }));
        default = {};
        description = "The mutators available to Sensu.";
      };

      sites = mkOption {
        type = listOf (submodule (import ./sites.nix { inherit lib; }));
        description = "The sites configured.";
        default = [];
      };

      plugins = mkOption {
        type = attrs;
        description = "Plugin configuration.";
        default = {};
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # Needed for being able to process UDP traffic
    boot.kernel.sysctl = lib.mkDefault {
      "net.core.rmem_max"     = 26214400;
      "net.core.rmem_default" = 26214400;
    };

    environment = let dir = "${lib.removePrefix "/etc/" baseDir}/conf.d"; in {
      etc = {
        checks = lib.mkIf roleIsServer {
          source = checkCfg;
          target = "${dir}/checks.json";
        };
        filters = lib.mkIf roleIsServer {
          source = filterCfg;
          target = "${dir}/filters.json";
        };
        handlers = lib.mkIf roleIsServer {
          source = handlerCfg;
          target = "${dir}/handlers.json";
        };
        tessen = lib.mkIf roleIsServer {
          source = tessenCfg;
          target = "${dir}/tessen.json";
        };
        # influxdb_line_protocol = {
          # source = "${cfg.package}/bin/mutator-influxdb-line-protocol.rb";
          # target = "sensu/extensions/mutator-influxdb-line-protocol.rb";
        # };
        uchiwa = lib.mkIf roleIsServer {
          source = dashCfg;
          target = "sensu/uchiwa.json";
        };
        client = {
          source = clientCfg;
          target = "${dir}/client.json";
        };
        config = {
          source = sensuCfg;
          target = "sensu/config.json";
        };
      };

      systemPackages = with pkgs; [
        jq
        nmap
        tree
      ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openDefaultPorts ([]
      ++ lib.optional (cfg.client.socket != "127.0.0.1") cfg.client.socket.port
      ++ lib.optional roleIsServer                       cfg.api.port
      ++ lib.optional (cfg.dashboard.enable)             cfg.dashboard.port
    );

    services = let pcfg = cfg.dashboard.proxy; in {
      nginx = lib.mkIf pcfg.enable {
        enable = true;
        virtualHosts = {
          "${pcfg.name}" = rec {
            addSSL     = pcfg.enableSSL;
            enableACME = addSSL;
            extraConfig = let
              inherit (pcfg) enable path;
            in ''
              location ${path} {
                proxy_pass http://${cfg.dashboard.host}:${toString cfg.dashboard.port};
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host $host;

                rewrite ${path}(.*) /$1 break;
              }
            '';
          };
        };
      };

      rabbitmq = lib.mkIf (roleIsServer && transportIsRabbitMQ) {
        enable = true;
      };

      redis = lib.mkIf roleIsServer {
        enable = true;
        bind = "127.0.0.1";
      };

      sensu = {
        checks = let
          disk = { warn = 20; crit = 10; };
          standardCheck = { command, ... } @attrs : let
            attrs' = builtins.removeAttrs attrs [ "command" ];
            cmd = builtins.head attrs.command;
            command' = lib.concatStringsSep " " attrs.command;
          in {
            dependencies = [ "keepalive" ];
            inherit (cfg.defaultSubscriptions) interval occurrences;
            command = ''
              if [ -x /run/sensu/libexec/wrapper.sh ]; then
                exec /run/sensu/libexec/wrapper.sh ${command'}
              else
                exec ${command'}
              fi
            '';
          } // attrs';
        in {
          sensu-disk-root = standardCheck {
            command = [
               "check_disk"
               "--warning=${toString disk.warn}"
               "--critical=${toString disk.crit}"
               "--path=/"
            ];
            subscribers = cfg.defaultServerSubscriptions ++ cfg.defaultClientSubscriptions;
          };

          sensu-disk-var = standardCheck {
            command = [
               "check_disk"
               "--warning=${toString disk.warn}"
               "--critical=${toString disk.crit}"
               "--path=/var"
            ];
            subscribers = cfg.defaultServerSubscriptions ++ cfg.defaultClientSubscriptions;
          };

          sensu-error-log = standardCheck {
            command = [
              "check-journal.rb"
              "--journalctl_args='-p err --quiet' -q ''"
              "-v"
            ];
            subscribers = cfg.defaultServerSubscriptions ++ cfg.defaultClientSubscriptions;
          };

          sensu-load = standardCheck {
            command = [
              "check_load"
              "--warning=3.50,3.25,3.00"
              "--critical=4.50,4.25,4.00"
              "--percpu"
            ];
            subscribers = cfg.defaultServerSubscriptions ++ cfg.defaultClientSubscriptions;
          };

          sensu-swap = standardCheck {
            command = [
              "check_swap"
              "--warning=50%"
              "--critical=20%"
              "--no-swap=ok"
            ];
            subscribers = cfg.defaultServerSubscriptions ++ cfg.defaultClientSubscriptions;
          };

          sensu-time = standardCheck {
            command = [
              "check_ntp_time"
              "-H :::vars.ntp.host|0.nixos.pool.ntp.org:::"
            ];
            subscribers = cfg.defaultServerSubscriptions;
          };

          sensu-uptime = standardCheck {
            command = [
              "check_uptime"
              "--warning 3:"
            ];
            subscribers = cfg.defaultServerSubscriptions ++ cfg.defaultClientSubscriptions;
          };

          sensu-influx-ping = standardCheck {
            command = [
              "check-influxdb.rb"
              "--host ${cfg.influxdb.host}"
              "--port ${toString cfg.influxdb.port}"
            ];
            subscribers = cfg.defaultServerSubscriptions;
          };

          sensu-redis-mem = standardCheck {
            command = [
              "check-redis-memory-percentage.rb"
              "--host ${cfg.redis.host}"
              "--port ${toString cfg.redis.port}"
              "--critmem 90"
              "--warnmem 70"
            ];
            subscribers = cfg.defaultServerSubscriptions;
          };
        };

        client.subscriptions = lib.mkIf cfg.defaultSubscriptions.enable (
           if roleIsServer then cfg.defaultServerSubscriptions
                           else cfg.defaultClientSubscriptions
        );

        extensions = {
          influxdb =  {
            gem = "sensu-extensions-influxdb2";
          };
        };
      };
    };

    systemd = let
      runRabbitMq = (roleIsServer && transportIsRabbitMQ && cfg.configureRabbitMq);
    in {
      services = {
        sensu-api       = lib.mkIf roleIsServer         (sensuService "API"       (bin "api"));
        sensu-client    = lib.mkIf roleIsClient         (sensuService "Client"    (bin "client"));
        sensu-server    = lib.mkIf roleIsServer         (sensuService "Server"    (bin "server"));
        sensu-dashboard = lib.mkIf cfg.dashboard.enable (sensuService "Dashboard"
          "${pkgs.uchiwa}/bin/uchiwa -c ${baseDir}/uchiwa.json"
        );

        rabbitmq = lib.mkIf runRabbitMq {
          wants = [ "rabbitmq-setup.service" ];
        };

        rabbitmq-setup = lib.mkIf runRabbitMq (
        let
          rmq = builtins.head config.services.sensu.rabbitmq;
          service = [ "rabbitmq.service" ];
        in lib.mkIf transportIsRabbitMQ {
          description = "Configure RabbitMQ queue and user for Sensu";
          wants = service;
          after = service;
          # we don't want the script to error out if the vhost and user already exist hence the || true
          environment.HOME = config.services.rabbitmq.dataDir;
          path = with pkgs; [ coreutils gnused rabbitmq-server ];
          script = ''
            rabbitmqctl add_vhost ${rmq.vhost} || true
            rabbitmqctl add_user  ${rmq.user} '${rmq.password}' || true
            rabbitmqctl set_permissions -p ${rmq.vhost} ${rmq.user} ".*" ".*" ".*" || true

            # get rid of guest
            rabbitmqctl delete_user guest || true
          '';
        });
      };

      targets.sensu = {
        description = "Sensu Monitoring";
        wantedBy    = [ "multi-user.target" ];
      };
    };

    users = lib.mkIf true {
      users.sensu = {
        description = "Sensu Monitoring";
        isSystemUser = true;
        group = "sensu";
        createHome = false;
        home = "/var/lib/sensu";
      };

      groups.sensu = {};
    };
  };
}
