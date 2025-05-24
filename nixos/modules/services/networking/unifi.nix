{
  config,
  options,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.unifi;

  stateDir = "/var/lib/unifi";

  cmd = lib.escapeShellArgs (
    [
      "@${cfg.jrePackage}/bin/java"
      "java"
      "--add-opens=java.base/java.lang=ALL-UNNAMED"
      "--add-opens=java.base/java.time=ALL-UNNAMED"
      "--add-opens=java.base/sun.security.util=ALL-UNNAMED"
      "--add-opens=java.base/java.io=ALL-UNNAMED"
      "--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"
    ]
    ++ lib.optionals (cfg.java.initialHeapSize != null) [
      "-Xms${(toString cfg.java.initialHeapSize)}m"
    ]
    ++ lib.optionals (cfg.java.maximumHeapSize != null) [
      "-Xmx${(toString cfg.java.maximumHeapSize)}m"
    ]
    ++ cfg.java.extraJvmOptions
    ++ [
      "-jar"
      "${stateDir}/lib/ace.jar"
    ]
  );

  properties = lib.recursiveUpdate {
    "unifi.http.port" = cfg.httpPort;
    "unifi.https.port" = cfg.httpsPort;
    "unifi.stun.port" = cfg.stunPort;
    "unifi.db.port" = 27117;
    "unifi.db.nojournal" = !cfg.database.journaling;
    "unifi.https.hsts" = cfg.enableHsts;
  } cfg.systemProperties;

  setupScript =
    let
      toStr = val: if builtins.isBool val then lib.boolToString val else toString val;

    in
    pkgs.resholve.writeScriptBin "unifi-setup"
      {
        interpreter = pkgs.runtimeShell;
        inputs = with pkgs; [
          coreutils
          crudini
        ];
        execer = [ "cannot:${lib.getExe pkgs.crudini}" ];
      }
      ''
        set -Euo pipefail

        props="${stateDir}/data/system.properties"

        rm -f ${stateDir}/webapps/ROOT
        ln -s ${cfg.unifiPackage}/webapps/ROOT ${stateDir}/webapps/ROOT

        touch $props

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: ''
            crudini --set $props "" ${name} ${toStr value}
          '') properties
        )}
      '';

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "unifi" "dataDir" ]
      "You should move contents of dataDir to /var/lib/unifi/data or to use external storage, configure unifi to use an external Mongo instance and configure that accordingly."
    )
    (lib.mkRenamedOptionModule [ "services" "unifi" "openPorts" ] [ "services" "unifi" "openFirewall" ])
    (lib.mkRenamedOptionModule
      [ "services" "unifi" "extraJvmOptions" ]
      [ "services" "unifi" "java" "extraJvmOptions" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "unifi" "jrePackage" ]
      [ "services" "unifi" "java" "package" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "unifi" "initialJavaHeapSize" ]
      [ "services" "unifi" "java" "initialHeapSize" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "unifi" "maximumJavaHeapSize" ]
      [ "services" "unifi" "java" "maximumHeapSize" ]
    )
  ];

  options.services.unifi = {
    enable = lib.mkEnableOption "the unifi controller service.";

    unifiPackage = lib.mkPackageOption pkgs "unifi" {
      default = "unifi8";
    };

    mongodbPackage = lib.mkPackageOption pkgs "mongodb" {
      default = "mongodb-7_0";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether or not to open the minimum required ports on the firewall.

        This is necessary to allow firmware upgrades and device discovery to
        work. For remote login, you should additionally open (or forward) port
        8443.
      '';
    };

    java = {
      package = lib.mkPackageOption pkgs "jdk" {
        default = "jdk17_headless";
        extraDescription = ''
          Check the UniFi controller release notes to ensure it is supported.
        '';
      };

      initialHeapSize = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        example = 1024;
        description = ''
          Set the initial heap size for the JVM in MB. If this option isn't set, the
          JVM will decide this value at runtime.
        '';
      };

      maximumHeapSize = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        example = 4096;
        description = ''
          Set the maximimum heap size for the JVM in MB. If this option isn't set, the
          JVM will decide this value at runtime.
        '';
      };

      extraJvmOptions = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = lib.literalExpression ''["-Xlog:gc"]'';
        description = ''
          Set extra options to pass to the JVM.
        '';
      };
    };

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = ''
        Port for AP inform
      '';
    };

    httpsPort = lib.mkOption {
      type = lib.types.port;
      default = 8443;
      description = ''
        Port for HTTPS traffic to controller UI.
      '';
    };

    stunPort = lib.mkOption {
      type = lib.types.port;
      default = 3478;
      description = ''
        Port for STUN traffic.
      '';
    };

    enableHsts = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable HSTS.
      '';
    };

    database.journaling = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use database journaling. Disable this to use less disk space in exchange for a higher risk of file corruption.
      '';
    };

    systemProperties = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Key-value pairs that will be written to system.properties
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          lib.versionAtLeast config.system.stateVersion "24.11"
          || (
            options.services.unifi.unifiPackage.highestPrio < (lib.mkOptionDefault { }).priority
            && options.services.unifi.mongodbPackage.highestPrio < (lib.mkOptionDefault { }).priority
          );
        message = ''
          Support for UniFi < 8 has been dropped; please explicitly set
          `services.unifi.unifiPackage` and `services.unifi.mongodbPackage`.

          Note that the previous default MongoDB version was 5.0 and MongoDB
          only supports migrating one major version at a time; therefore, you
          may wish to set `services.unifi.mongodbPackage = pkgs.mongodb-6_0;`
          and activate your configuration before upgrading again to the default
          `mongodb-7_0` supported by `unifi`.

          For more information, see the MongoDB upgrade notes:
          <https://www.mongodb.com/docs/manual/release-notes/7.0-upgrade-standalone/#upgrade-recommendations-and-checklists>
        '';
      }
    ];

    users = {
      users.unifi = {
        isSystemUser = true;
        group = "unifi";
        description = "UniFi controller daemon user";
        home = stateDir;
      };
      groups.unifi = { };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
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
        restartTriggers = [
          cfg.unifiPackage
          cfg.mongodbPackage
        ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${lib.removeSuffix "\n" cmd} start";
          ExecStop = "${lib.removeSuffix "\n" cmd} stop";
          Restart = "on-failure";
          TimeoutSec = "5min";
          User = "unifi";
          UMask = "0077";
          WorkingDirectory = stateDir;
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

    systemd = {
      targets.unifi = {
        description = "UniFi Controller";
        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.rules =
        [
          "d ${stateDir} 0700 unifi unifi - -"
        ]
        ++ (map (e: "d ${stateDir}/${e} 0700 unifi unifi - -") [
          "data"
          "logs"
          "run"
          "webapps"
        ])
        ++ [ "Z ${stateDir} - unifi unifi - -" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    erictapen
    pennae
    peterhoeg
  ];
}
