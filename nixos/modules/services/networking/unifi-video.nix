{ config, lib, pkgs, utils, ... }:

with lib;

let
  cfg = config.services.unifi-video;
  stateDir = "/var/lib/unifi-video";
  cmd = "@${pkgs.jre}/bin/java com.ubnt.airvision.Main";
  mountPoints = [
    {
      what = "${pkgs.unifi-video}/dl";
      where = "${stateDir}/dl";
    }
    {
      what = "${pkgs.unifi-video}/lib";
      where = "${stateDir}/lib";
    }
    {
      what = "${pkgs.mongodb}/bin";
      where = "${stateDir}/bin";
    }
    {
      what = "${cfg.dataDir}";
      where = "${stateDir}/data";
    }
  ];
  systemdMountPoints = map (m: "${utils.escapeSystemdPath m.where}.mount") mountPoints;

in {

  options = {
    services.unifi-video.enable = mkEnableOption "Whether or not to enable the unifi video service.";

    services.unifi-video.dataDir = mkOption {
      type = types.str;
      default = "${stateDir}/data";
      description = ''
        Where to store the database and other data.

        This directory will be bind-mounted to ${stateDir}/data as part of the service startup.
      '';
    };
  };

  config = mkIf cfg.enable {

    users.extraUsers.unifi = {
      uid = config.ids.uids.unifi-video;
      description = "UniFi Video daemon user";
      home = "${stateDir}";
    };

    # We must create the binary directories as bind mounts instead of symlinks
    # This is because the controller resolves all symlinks to absolute paths
    # to be used as the working directory.
    systemd.mounts = map ({ what, where }: {
        bindsTo = [ "unifi-video.service" ];
        partOf = [ "unifi-video.service" ];
        unitConfig.RequiresMountsFor = stateDir;
        options = "bind";
        what = what;
        where = where;
      }) mountPoints;

    systemd.services.unifi-video = {
      description = "UniFi video daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ] ++ systemdMountPoints;
      partOf = systemdMountPoints;
      bindsTo = systemdMountPoints;
      unitConfig.RequiresMountsFor = stateDir;
      # This a HACK to fix missing dependencies of dynamic libs extracted from jars
      environment.LD_LIBRARY_PATH = with pkgs.stdenv; "${cc.cc.lib}/lib";

      preStart = ''
        # Ensure privacy of state
        install -d -m0700 -o unifi-video "${stateDir}"

        # Create the volatile webapps
        rm -rf "${stateDir}/webapps"
        install -d -m0700 -o unifi-video "${stateDir}/webapps"
        ln -s "${pkgs.unifi-video}/webapps/ROOT" "${stateDir}/webapps/ROOT"
      '';

      postStop = ''
        rm -rf "${stateDir}/webapps"
      '';

      serviceConfig = {
        ExecStart = "${cmd} start";
        ExecStop = "${cmd} stop";
        User = "unifi-video";
        PermissionsStartOnly = true;
        UMask = "0077";
        WorkingDirectory = "${stateDir}";
        ProtectSystem = "full";
        PrivateTmp = true;
      };
    };
  };
}
