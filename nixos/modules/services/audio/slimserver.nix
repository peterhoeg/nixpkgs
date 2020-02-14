{ config, lib, pkgs, ... }:

with lib;

let
  dirName = "slimserver";
  cfg = config.services.slimserver;

in
{
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
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.slimserver = {
      description = "Slim Server for Logitech Squeezebox Players";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = rec {
        Type = "exec";
        ExecStart = lib.concatStringsSep " " [
          "${cfg.package}/slimserver.pl"
          "--logdir /var/log/${dirName}"
          # Preferences should just go into /var/lib/slimserver instead of a
          # prefs subdir but to avoid having to deal with migrating it, it's
          # easier just to leave it
          "--prefsdir /var/lib/${dirName}/prefs"
          "--cachedir /var/cache/${dirName}"
          # Issue 40589: Disable broken image/video support (audio still works!)
          "--noimage --novideo"
        ];
        DynamicUser = true;
        StateDirectory = dirName;
        CacheDirectory = dirName;
        LogsDirectory = dirName;
        Restart = "on-failure";
      };
    };

  };

}
