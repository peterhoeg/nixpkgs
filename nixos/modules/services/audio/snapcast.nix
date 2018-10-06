{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.snapcast;

  defaultStream = "pipe:///run/snapserver/fifo?name=default";

  serverStart = lib.concatStringsSep " " ([
    "${pkgs.snapcast}/bin/snapserver"
    "--port ${toString cfg.server.port}"
    "--controlPort ${toString cfg.server.controlPort}"
    "--codec ${cfg.server.codec}"
    "--sampleformat ${cfg.server.sampleFormat}"
  ] ++ map (s: "--stream '${s}'") cfg.server.streams);

  clientStart = lib.concatStringsSep " " [
    "${pkgs.snapcast}/bin/snapclient"
    "--soundcard ${cfg.client.soundCard}"
    "--host ${cfg.client.host}"
    "--port ${toString cfg.client.port}"
  ];

  commonConfig = {
    DynamicUser = true;
    Restart = "on-failure";
  };

in {
  options = {
    services.snapcast = {
      server = {
        enable = mkEnableOption "SnapCast server";

        port = mkOption {
          type = types.int;
          default = 1704;
          description = "Server port";
        };

        controlPort = mkOption {
          type = types.int;
          default = 1705;
          description = "Remote control port";
        };

        codec = mkOption {
          type = types.enum [ "flac" "ogg" "pcm" ];
          default = "flac";
          description = "Transport codec";
        };

        sampleFormat = mkOption {
          type = types.str;
          default = "48000:16:2";
          description = "Sample format";
        };

        streams = mkOption {
          type = types.listOf types.str;
          default = [ defaultStream ];
          description = ''
            If you override this, you probably want to supply the default stream as well: ${defaultStream}
          '';
        };
      };

      client = {
        enable = mkEnableOption "SnapCast client";

        soundCard = mkOption {
          type = types.str;
          default = "default";
          description = "Index or name of soundcard";
        };

        host = mkOption {
          type = types.str;
          description = "Server hostname or IP address";
        };

        port = mkOption {
          type = types.int;
          default = 1704;
          description = "Server port";
        };
      };
    };
  };


  ###### implementation

  config.systemd.services.snapserver = mkIf cfg.server.enable rec {
    description = "SnapCast server";
    after = [ "network-online.target" ];
    requires = after;
    wantedBy = [ "multi-user.target" ];

    serviceConfig = commonConfig // {
      ExecStart = serverStart;
      StateDirectory = "snapserver";
      RuntimeDirectory = "snapserver";
    };
  };

  config.systemd.services.snapclient = mkIf cfg.client.enable rec {
    description = "SnapCast client";
    after = [ "network-online.target" "sound.target" ];
    requires = after;
    wants = [ "avahi-daemon.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = commonConfig // {
      ExecStart = clientStart;
      StateDirectory = "snapclient";
      SupplementaryGroups = [ "audio" ];
    };
  };
}
