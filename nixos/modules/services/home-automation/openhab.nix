{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.openhab;

  libDir = "/var/lib/openhab";

in {
  meta.maintainers = with maintainers; [ peterhoeg ];

  options.services.openhab = {
    enable = mkEnableOption "OpenHAB - home automation";

    package = mkOption {
      default = pkgs.openhab;
      type = types.package;
      example = literalExample ''
        pkgs.openhab.override {
          withAddons = true;
          addons = [ someLocallyDefinedPackage someJavaPackage ];
        }
      '';
      description = ''
        OpenHAB package to use with overrides for additional addons.
      '';
    };

    configDrv = mkOption {
      default = null;
      type = types.nullOr types.package;
      description = ''
        If you want to configure OpenHAB declaratively, provide a derivation
        with all the config files you want to override inside etc/openhab/{conf,userdata}.
        </para>
        <para>
        Any existing files under ${libDir}/{conf,userdata} will be overwritten
        by the files from here.
      '';
    };

    resetConfigurationOnRestart = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Whether to remove all locally created configuration on service restart.
        </para>
        <para>
        This is very useful when you are building up a new configuration but
        keep in mind, that it will make the initial service start
        *significantly* longer if you are running on a low-power machine (RPI)
        and you probably don't want this set permanently to true.
      '';
    };

    java = {
      package = mkOption {
        default = pkgs.jre8;
        example = "pkgs.oraclejdk8";
        type = types.package;
        description = ''
          By default we are using OpenJDK as the Java run-time due to it being
          open source, but if you want to connect to an instance of OpenHAB
          cloud either self-hosted with Let's Encrypt certificates or
          myopenhab.org, you *will* need the Oracle JRE instead due to OpenJDK
          missing support for various encryption providers.
        '';
      };

      elevatePermissions = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Some bindings will require the java process to have additional
          permissions. Enabling this will configure a wrapper that does that.
        '';
      };
    };

    httpPort = mkOption {
      default = 8080;
      type = types.int;
      description = "The port on which to listen for HTTP.";
    };

    httpsPort = mkOption {
      default = 8443;
      type = types.int;
      description = "The port on which to listen for HTTPS.";
    };

    openFirewall = mkOption {
      default = false;
      type = types.bool;
      description = "Whether to open the firewall for the specified ports.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.httpPort cfg.httpsPort ];

    security.wrappers.java = lib.mkIf cfg.java.elevatePermissions {
      source = "${cfg.java.package}/bin/java";
      capabilities = "cap_net_raw,cap_net_admin=+eip cap_net_bind_service=+ep";
    };

    systemd.services.openhab = rec {
      description = "openHAB - empowering the smart home";
      documentation = [
        https://www.openhab.org/docs/
        https://community.openhab.org
      ];
      wants = [ "network-online.target" ];
      after = wants;
      wantedBy = [ "multi-user.target" ];

      path = lib.mkIf cfg.java.elevatePermissions [
        "/run/wrappers"
      ];

      environment = {
        OPENHAB_CONF = "${libDir}/conf";
        OPENHAB_USERDATA = "${libDir}/userdata";
        OPENHAB_HTTP_PORT = toString cfg.httpPort;
        OPENHAB_HTTPS_PORT = toString cfg.httpsPort;
      };

      preStart = ''
        set -euo pipefail

        test -e ${cfg.java.package}/nix-support/setup-hook && source ${cfg.java.package}/nix-support/setup-hook

        ${lib.optionalString cfg.resetConfigurationOnRestart ''
          # Resetting all configuration
          rm -rf $OPENHAB_CONF $OPENHAB_USERDATA
        ''}

        # Copy in default configuration
        if [ ! -d $OPENHAB_CONF ]; then
          cp --no-preserve=owner,mode -r ${cfg.package}/share/openhab/conf $OPENHAB_CONF
        fi

        if [ ! -d $OPENHAB_USERDATA ]; then
          cp --no-preserve=owner,mode -r ${cfg.package}/share/openhab/userdata $OPENHAB_USERDATA
        fi

        ${lib.optionalString (cfg.configDrv != null) ''
          # recursively copy and symlink files into place
          cp -sRf ${cfg.configDrv}/etc/openhab/* ${libDir}/
        ''}
      '';

      serviceConfig = {
        DynamicUser = true;
        SupplementaryGroups = [ "audio" "dialout" "tty" ];
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];
        PrivateTmp = true;
        ExecStart = "${cfg.package}/bin/openhab run";
        ExecStop = "${cfg.package}/bin/openhab stop";
        LogsDirectory  = builtins.baseNameOf libDir;
        StateDirectory = builtins.baseNameOf libDir;
        WorkingDirectory = libDir;
        ProtectSystem = "strict";
        ProtectHome = "tmpfs";
        SuccessExitStatus="0 143";
        RestartSec = "5s";
        Restart = "on-failure";
        TimeoutStopSec = "120";
        LimitNOFILE = "102642";
      };
    };
  };
}
