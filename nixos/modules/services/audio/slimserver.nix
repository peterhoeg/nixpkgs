{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.slimserver;

  defaultDataDir = "/var/lib/slimserver";
  customDataDir = defaultDataDir != cfg.dataDir;

in {
  options = {

    services.slimserver = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable slimserver.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.slimserver;
        defaultText = "pkgs.slimserver";
        description = "Slimserver package to use.";
      };

      dataDir = mkOption {
        type = types.path;
        default = defaultDataDir;
        description = ''
          The directory where slimserver stores its state, tag cache,
          playlists etc.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.slimserver = {
      after = [ "network.target" ];
      description = "Slim Server for Logitech Squeezebox Players";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = rec {
        ExecStartPre = lib.mkIf customDataDir "!mkdir -p ${cfg.dataDir} && chown -R slimserver:slimserver ${cfg.dataDir}";
        # Issue 40589: Disable broken image/video support (audio still works!)
        ExecStart = "${cfg.package}/slimserver.pl --logdir /var/log/${LogsDirectory} --prefsdir ${cfg.dataDir}/prefs --cachedir ${cfg.dataDir}/cache --noimage --novideo";
        StateDirectory = builtins.baseNameOf defaultDataDir;
        LogsDirectory = StateDirectory;
        DynamicUser = true;
        ReadWritePaths = lib.mkIf customDataDir [ cfg.dataDir ];
      };
    };
  };
}

