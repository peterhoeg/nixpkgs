{ config, lib, pkgs, ... }:

let
  inherit (lib)
    any optionalAttrs optionalString
    literalExpression
    mkRenamedOptionModule mkRemovedOptionModule
    mkDefault mkIf mkMerge mkOption types;

  inInitrd = any (fs: fs == "nfs") config.boot.initrd.supportedFilesystems;

  nfsStateDir = "/var/lib/nfs";

  rpcMountpoint = "${nfsStateDir}/rpc_pipefs";

  cfgFmt = pkgs.formats.ini { };

  idmapdConfFile = cfgFmt.generate "idmapd.conf" cfg.idmapd.settings;
  nfsConfFile = cfgFmt.generate "nfs.conf" cfg.settings;
  requestKeyConfFile = pkgs.writeText "request-key.conf" ''
    create id_resolver * * ${pkgs.nfs-utils}/bin/nfsidmap -t 600 %k %d
  '';

  cfg = config.services.nfs;

in

{
  imports = [
    (mkRemovedOptionModule [ "services" "nfs" "extraConfig" ] "See services.nfs.settings")
  ];

  ###### interface

  options.services.nfs = {
    idmapd.settings = mkOption {
      type = cfgFmt.type;
      default = { };
      description = ''
        libnfsidmap configuration. Refer to
        <link xlink:href="https://linux.die.net/man/5/idmapd.conf"/>
        for details.
      '';
      example = literalExpression ''
        {
          Translation = {
            GSS-Methods = "static,nsswitch";
          };
          Static = {
            "root/hostname.domain.com@REALM.COM" = "root";
          };
        }
      '';
    };

    settings = mkOption {
      type = cfgFmt.type;
      default = { };
      description = ''
        RFC42 compliant settings
      '';
    };
  };

  ###### implementation

  config = mkIf (any (fs: fs == "nfs" || fs == "nfs4") config.boot.supportedFilesystems) {

    services.rpcbind.enable = true;

    services.nfs.idmapd.settings = {
      General = {
        Pipefs-Directory = rpcMountpoint;
      } // optionalAttrs (config.networking.domain != null) { Domain = config.networking.domain; };
      Mapping = {
        Nobody-User = "nobody";
        Nobody-Group = "nogroup";
      };
      Translation = {
        Method = "nsswitch";
      };
    };

    system.fsPackages = [ pkgs.nfs-utils ];

    boot.initrd.kernelModules = mkIf inInitrd [ "nfs" ];

    systemd.packages = [ pkgs.nfs-utils ];

    environment.systemPackages = [ pkgs.keyutils ];

    environment.etc = {
      "idmapd.conf".source = idmapdConfFile;
      "nfs.conf".source = nfsConfFile;
      "request-key.conf".source = requestKeyConfFile;
    };

    systemd.targets.nfs-client = {
      wantedBy = [ "multi-user.target" "remote-fs.target" ];
    };

    systemd.services = {
      auth-rpcgss-module.unitConfig.ConditionPathExists = [ "" "/etc/krb5.keytab" ];

      nfs-blkmap.restartTriggers = [ nfsConfFile ];

      nfs-idmapd.restartTriggers = [ idmapdConfFile ];

      nfs-mountd.restartTriggers = [ nfsConfFile ];

      nfs-server.restartTriggers = [ nfsConfFile ];

      rpc-gssd = {
        restartTriggers = [ nfsConfFile ];
        unitConfig.ConditionPathExists = [ "" "/etc/krb5.keytab" ];
      };

      rpc-statd.restartTriggers = [ nfsConfFile ];
    };
  };
}
