{ config, options, lib, pkgs, utils, ... }:

let
  inherit (lib)
    concatStringsSep mapAttrsToList recursiveUpdate
    optionalString optional removeSuffix
    mkIf mkOption mkOptionDefault mkEnableOption literalExpression types
    mkRemovedOptionModule mkRenamedOptionModule;

  cfg = config.services.unifi;

  stateDir = "/var/lib/unifi";

  cmd = concatStringsSep " " ([
    "@${cfg.java.package}/bin/java java"
  ]
  ++ optional (cfg.java.initialHeapSize != null) "-Xms${(toString cfg.java.initialHeapSize)}m"
  ++ optional (cfg.java.maximumHeapSize != null) "-Xmx${(toString cfg.java.maximumHeapSize)}m"
  ++ [
    "-jar ${stateDir}/lib/ace.jar"
  ]);

  properties = recursiveUpdate
    {
      "unifi.http.port" = cfg.httpPort;
      "unifi.https.port" = cfg.httpsPort;
      "unifi.stun.port" = cfg.stunPort;
      "unifi.db.port" = 27117;
      "unifi.db.nojournal" = ! cfg.database.journaling;
      "unifi.https.hsts" = cfg.enableHsts;
    }
    cfg.systemProperties;

  setupScript =
    let
      toStr = val:
        if builtins.isBool val
        then lib.boolToString val
        else toString val;

    in
    pkgs.resholve.writeScriptBin "unifi-setup"
      {
        interpreter = lib.getExe pkgs.bash;
        inputs = with pkgs; [ coreutils crudini ];
        execer = [ "cannot:${lib.getExe pkgs.crudini}" ];
      }
      ''
        set -Euo pipefail

        props="${stateDir}/data/system.properties"

        rm -f ${stateDir}/webapps/ROOT
        ln -s ${cfg.unifiPackage}/webapps/ROOT ${stateDir}/webapps/ROOT

        touch $props

        ${concatStringsSep "\n" (mapAttrsToList (name: value: ''
          crudini --set $props "" ${name} ${toStr value}
        '') properties)}
      '';

in
{
  imports = [
    (mkRemovedOptionModule [ "services" "unifi" "dataDir" ] "You should move contents of dataDir to /var/lib/unifi/data or to use external storage, configure unifi to use an external Mongo instance and configure that accordingly.")
    (mkRenamedOptionModule [ "services" "unifi" "openPorts" ] [ "services" "unifi" "openFirewall" ])
  ];

  options.services.unifi = {
    enable = mkEnableOption "the unifi controller service.";

    unifiPackage = mkOption {
      type = types.package;
      default = pkgs.unifiLTS;
      defaultText = literalExpression "pkgs.unifiLTS";
      description = ''
        The unifi package to use.
      '';
    };

    mongodbPackage = mkOption {
      type = types.package;
      default = pkgs.mongodb;
      defaultText = literalExpression "pkgs.mongodb";
      description = ''
        The mongodb package to use.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether or not to open the minimum required ports on the firewall.

        This is necessary to allow firmware upgrades and device discovery to
        work. For remote login, you should additionally open (or forward) port
        8443.
      '';
    };

    java = {
      package = mkOption {
        type = types.package;
        default = pkgs.jre8;
        defaultText = literalExpression "pkgs.jre8";
        description = ''
          The JRE package to use. Check the release notes to ensure it is supported.
        '';
      };

      initialHeapSize = mkOption {
        type = types.nullOr types.int;
        default = null;
        example = 1024;
        description = ''
          Set the initial heap size for the JVM in MB. If this option isn't set, the
          JVM will decide this value at runtime.
        '';
      };

      maximumHeapSize = mkOption {
        type = types.nullOr types.int;
        default = null;
        example = 4096;
        description = ''
          Set the maximimum heap size for the JVM in MB. If this option isn't set, the
          JVM will decide this value at runtime.
        '';
      };
    };

    httpPort = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        Port for AP inform
      '';
    };

    httpsPort = mkOption {
      type = types.port;
      default = 8443;
      description = ''
        Port for HTTPS traffic to controller UI.
      '';
    };

    stunPort = mkOption {
      type = types.port;
      default = 3478;
      description = ''
        Port for STUN traffic.
      '';
    };

    enableHsts = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable HSTS.
      '';
    };

    database.journaling = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Use database journaling. Disable this to use less disk space in exchange for a higher risk of file corruption.
      '';
    };

    systemProperties = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Key-value pairs that will be written to system.properties
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.unifi = {
      isSystemUser = true;
      group = "unifi";
      description = "UniFi controller daemon user";
      home = stateDir;
    };
    users.groups.unifi = { };

    networking.firewall = mkIf cfg.openFirewall {
      # https://help.ubnt.com/hc/en-us/articles/218506997
      allowedTCPPorts = [
        cfg.httpPort # Port for UAP to inform controller.
        cfg.httpsPort # Port for controller UI/API.
        8880 # Port for HTTP portal redirect, if guest portal is enabled.
        8843 # Port for HTTPS portal redirect, ditto.
        6789 # Port for UniFi mobile speed test.
      ];
      allowedUDPPorts = [
        cfg.stunPort # UDP port used for STUN.
        10001 # UDP port used for device discovery.
      ];
    };

    systemd.services = {
      unifi-setup = {
        description = "UniFi controller daemon - setup";
        wantedBy = [ "unifi.target" ];
        before = [ "unifi.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "unifi";
          Group = "unifi";
          ExecStart = lib.getExe setupScript;
        };
      };

      unifi = {
        description = "UniFi controller daemon";
        wantedBy = [ "unifi.target" ];
        after = [ "network.target" ];

        # This a HACK to fix missing dependencies of dynamic libs extracted from jars
        environment.LD_LIBRARY_PATH = with pkgs.stdenv; "${cc.cc.lib}/lib";
        # Make sure package upgrades trigger a service restart
        restartTriggers = [ cfg.unifiPackage cfg.mongodbPackage ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${(removeSuffix "\n" cmd)} start";
          ExecStop = "${(removeSuffix "\n" cmd)} stop";
          Restart = "on-failure";
          TimeoutSec = "5min";
          User = "unifi";
          UMask = "0077";
          WorkingDirectory = "${stateDir}";
          # the stop command exits while the main process is still running, and unifi
          # wants to manage its own child processes. this means we have to set KillSignal
          # to something the main process ignores, otherwise every stop will have unifi.service
          # fail with SIGTERM status.
          KillSignal = "SIGCONT";

          # Hardening
          AmbientCapabilities = "";
          CapabilityBoundingSet = "";
          # ProtectClock= adds DeviceAllow=char-rtc r
          DeviceAllow = "";
          DevicePolicy = "closed";
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallErrorNumber = "EPERM";
          SystemCallFilter = [ "@system-service" ];

          StateDirectory = "unifi";
          RuntimeDirectory = "unifi";
          LogsDirectory = "unifi";
          CacheDirectory = "unifi";

          TemporaryFileSystem = [
            # required as we want to create bind mounts below
            "${stateDir}/webapps:rw"
          ];

          # We must create the binary directories as bind mounts instead of symlinks
          # This is because the controller resolves all symlinks to absolute paths
          # to be used as the working directory.
          BindPaths = [
            "/var/log/unifi:${stateDir}/logs"
            "/run/unifi:${stateDir}/run"
            "${cfg.unifiPackage}/dl:${stateDir}/dl"
            "${cfg.unifiPackage}/lib:${stateDir}/lib"
            "${cfg.mongodbPackage}/bin:${stateDir}/bin"
            "${cfg.unifiPackage}/webapps/ROOT:${stateDir}/webapps/ROOT"
          ];

          # Needs network access
          PrivateNetwork = false;
          # Cannot be true due to OpenJDK
          MemoryDenyWriteExecute = false;
        };
      };
    };

    systemd.targets.unifi = {
      description = "UniFi Controller";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${stateDir} 0700 unifi unifi - -"
    ]
    ++ (map (e: "d ${stateDir}/${e} 0700 unifi unifi - -")
      [ "data" "logs" "run" "webapps" ])
    ++ [ "Z ${stateDir} - unifi unifi - -" ];
  };

  meta.maintainers = with lib.maintainers; [ erictapen pennae peterhoeg ];
}
