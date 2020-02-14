{ config, lib, pkgs, ... }:

with lib;

let
  dataDir = "/var/lib/squeezelite";
  cfg = config.services.squeezelite;


in
{

  ###### interface

  options = {

    services.squeezelite = {

      enable = mkEnableOption "Squeezelite, a software Squeezebox emulator";

      extraArguments = mkOption {
        default = "";
        type = types.str;
        description = ''
          Additional command line arguments to pass to Squeezelite.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.squeezelite = {
      description = "Software Squeezebox emulator";
      after = [ "network.target" "sound.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "exec";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.squeezelite}/bin/squeezelite"
          "-N ${dataDir}/player-name"
          cfg.extraArguments
        ];
        DynamicUser = true;
        StateDirectory = builtins.baseNameOf dataDir;
        SupplementaryGroups = "audio";
        Restart = "on-failure";
      };
    };

  };

}
