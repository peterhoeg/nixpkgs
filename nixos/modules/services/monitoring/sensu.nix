{ config, pkgs, lib, ... }:

let

  cfg = config.services.sensu;

  bin = binary:
    "${pkgs.sensu}/bin/sensu-${binary} -c ${sensuCfg} -d /etc/sensu/conf.d";

  serviceCfg = {
    User = "sensu";
    Group = "sensu";
    Slice = "sensu.slice";
    PrivateTmp = true;
    Restart = "on-failure";
  };

  sensuCfg = pkgs.writeText "config.json" ''
    {
      "redis": {
        "host": "127.0.0.1",
        "port": 6379
      },
      "transport": {
        "name": "redis",
        "reconnect_on_error": true
      },
      "api": {
        "host": "127.0.0.1",
        "port": 4567
      }
    }
  '';

  clientCfg = pkgs.writeText "client.json" ''
    {
      "client": {
        "name": "client-01",
        "address": "127.0.0.1",
        "environment": "development",
        "subscriptions": [
          "production"
        ],
        "socket": {
          "bind": "127.0.0.1",
          "port": 3030
        }
      }
    }
  '';

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

      transport = mkOption {
        type = types.enum [ "redis" "rabbitmq" ];
        default = "redis";
        description = "The transport to use.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.etc = {
      "sensu/config.json".source = sensuCfg;
      "sensu/conf.d/client.json".source = clientCfg;
    };

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
      packages = [ pkgs.sensu ];

      services = {
        sensu-server = {
          description = "Sensu Server";
          wantedBy = defaultTarget;
          serviceConfig = serviceCfg // {
            ExecStart = bin "server";
          };
        };

        sensu-api =  {
          description = "Sensu API Server";
          wantedBy = defaultTarget;
          serviceConfig = serviceCfg // {
            ExecStart = bin "api";
          };
        };

        sensu-client =  {
          description = "Sensu Client";
          wantedBy = defaultTarget;
          serviceConfig = serviceCfg // {
            ExecStart = bin "client";
          };
        };
      };
    };
  };
}
