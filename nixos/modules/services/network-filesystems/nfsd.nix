{ config, lib, pkgs, ... }:

let
  inherit (lib)
    optionalAttrs optionalString
    mkRenamedOptionModule
    mkEnableOption mkIf mkOption types;

  cfg = config.services.nfs.server;

  exports = pkgs.writeText "exports" cfg.exports;

  rpcUser = "nfs";

in
{
  imports = [
    (mkRenamedOptionModule [ "services" "nfs" "lockdPort" ] [ "services" "nfs" "server" "lockdPort" ])
    (mkRenamedOptionModule [ "services" "nfs" "statdPort" ] [ "services" "nfs" "server" "statdPort" ])
    (mkRenamedOptionModule [ "services" "nfs" "server" "extraNfsdConfig" ] [ "services" "nfs" "settings" ])
  ];

  ###### interface

  options.services.nfs.server = {
    enable = mkEnableOption "kernel's NFS server";

    exports = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Contents of the /etc/exports file.  See
        <citerefentry><refentrytitle>exports</refentrytitle>
        <manvolnum>5</manvolnum></citerefentry> for the format.
      '';
    };

    hostName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Hostname or address on which NFS requests will be accepted.
        Default is all.  See the <option>-H</option> option in
        <citerefentry><refentrytitle>nfsd</refentrytitle>
        <manvolnum>8</manvolnum></citerefentry>.
      '';
    };

    nproc = mkOption {
      type = types.ints.positive;
      default = 8;
      description = ''
        Number of NFS server threads.  Defaults to the recommended value of 8.
      '';
    };

    createMountPoints = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to create the mount points in the exports file at startup time.";
    };

    mountdPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 4002;
      description = ''
        Use fixed port for rpc.mountd, useful if server is behind firewall.
      '';
    };

    lockdPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 4001;
      description = ''
        Use a fixed port for the NFS lock manager kernel module
        (<literal>lockd/nlockmgr</literal>).  This is useful if the
        NFS server is behind a firewall.
      '';
    };

    statdPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 4000;
      description = ''
        Use a fixed port for <command>rpc.statd</command>. This is
        useful if the NFS server is behind a firewall.
      '';
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    services.nfs.settings = {
      nfsd = { threads = cfg.nproc; }
        // optionalAttrs (cfg.hostName != null) { host = cfg.hostName; };

      mountd = { } // optionalAttrs (cfg.mountdPort != null) { port = cfg.mountdPort; };

      statd = { } // optionalAttrs (cfg.statdPort != null) { port = cfg.statdPort; };

      lockd = { } // optionalAttrs (cfg.lockdPort != null) {
        port = cfg.lockdPort;
        udp-port = cfg.lockdPort;
      };
    };

    services.rpcbind.enable = true;

    boot.supportedFilesystems = [ "nfs" ]; # needed for statd and idmapd

    environment.etc.exports.source = exports;

    systemd.services = {
      nfs-server.wantedBy = [ "multi-user.target" ];

      nfs-mountd = {
        restartTriggers = [ exports ];

        preStart = optionalString cfg.createMountPoints ''
          # create export directories:
          # skip comments, take first col which may either be a quoted
          # "foo bar" or just foo (-> man export)
          sed '/^#.*/d;s/^"\([^"]*\)".*/\1/;t;s/[ ].*//' ${exports} \
          | xargs -d '\n' mkdir -p
        '';
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nfs            0755 ${rpcUser} ${rpcUser} - -"
      "d /var/lib/nfs/rpc_pipefs 0555 root       root       - -"
      "d /var/lib/nfs/sm         0700 ${rpcUser} root       - -"
      "d /var/lib/nfs/sm.bak     0700 ${rpcUser} root       - -"
      "d /var/lib/nfs/v4recovery 0755 root       root       - -"
      "d /var/lib/nfs/nfsdcld    0775 root       ${rpcUser} - -"
    ];

    users = {
      groups."${rpcUser}" = { };

      users."${rpcUser}" = {
        description = "NFS RPC user";
        group = rpcUser;
        isSystemUser = true;
      };
    };
  };
}
