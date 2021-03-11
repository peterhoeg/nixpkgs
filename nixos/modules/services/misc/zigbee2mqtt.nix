{ config, lib, pkgs, ... }:

let
  cfg = config.services.zigbee2mqtt;

  dataDir = "/var/lib/zigbee2mqtt";

  inherit (lib)
    literalExample mkEnableOption mkIf mkOption types
    mkRemovedOptionModule mkRenamedOptionModule
    recursiveUpdate;

  yml = pkgs.formats.yaml { };

  configFile =
    yml.generate "configuration.yaml" finalConfig;

  # the default config contains all required settings,
  # so the service starts up without crashing.
  finalConfig = recursiveUpdate
    {
      homeassistant = false;
      permit_join = false;
      advanced = {
        # Not logging to a file by default but set up sane defaults in case it is enabled
        log_directory = "/var/log/${builtins.baseNameOf dataDir}";
        log_file = "server_%TIMESTAMP%.log";
        log_output = [ "console" ];
        # Logging to journald, so there is not point adding an additional timestamp.
        # If you set this to "", zigbee2mqtt will use its default
        timestamp_format = " ";
      };
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://localhost:1883";
      };
      serial.port = "/dev/ttyACM0";
      # put device configuration into separate file because configuration.yaml
      # is copied from the store on startup
      devices = "devices.yaml";
    }
    cfg.settings;

in
{
  meta.maintainers = with lib.maintainers; [ sweber ];

  imports = [
    (mkRenamedOptionModule [ "services" "zigbee2mqtt" "config" ] [ "services" "zigbee2mqtt" "settings" ])
    (mkRemovedOptionModule [ "services" "zigbee2mqtt" "dataDir" ] ''
      zigbee2mqtt now runs with DynamicUser=true.
      Move your data into /var/lib/zigbee2mqtt if you were using a custom dataDir.
    '')
  ];

  options.services.zigbee2mqtt = {
    enable = mkEnableOption "zigbee2mqtt service";

    package = mkOption {
      description = "Zigbee2mqtt package to use";
      type = types.package;
      default = pkgs.zigbee2mqtt;
      defaultText = "pkgs.zigbee2mqtt";
    };

    settings = mkOption {
      description = "Your <filename>configuration.yaml</filename> as a Nix attribute set.";
      type = yml.type;
      default = { };
      example = literalExample ''
        {
          homeassistant = config.services.home-assistant.enable;
          permit_join = true;
          serial = {
            port = "/dev/ttyACM1";
          };
        }
      '';
    };
  };

  config = mkIf (cfg.enable) {
    systemd.services.zigbee2mqtt = {
      description = "Zigbee2mqtt Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      unitConfig.ConditionPathExists = finalConfig.serial.port;
      environment.ZIGBEE2MQTT_DATA = dataDir;
      serviceConfig = {
        DynamicUser = true;
        ExecStartPre = "${pkgs.coreutils}/bin/ln -sf ${configFile} ${dataDir}/${configFile.name}";
        ExecStart = "${cfg.package}/bin/zigbee2mqtt";
        WorkingDirectory = dataDir;
        Restart = "on-failure";
        ProtectHome = "tmpfs";
        ProtectSystem = "strict";
        LogsDirectory = builtins.baseNameOf dataDir;
        StateDirectory = builtins.baseNameOf dataDir;
        SupplementaryGroups = [ "dialout" ];
      };
    };
  };
}
