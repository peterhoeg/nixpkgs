{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.powerdns;
  libDir = "/var/lib/powerdns";
  configDir = pkgs.writeTextDir "pdns.conf" "${cfg.extraConfig}";
in {
  options = {
    services.powerdns = {
      enable = mkEnableOption "Powerdns domain name server";

      extraConfig = mkOption {
        type = types.lines;
        default = "launch=bind";
        description = ''
          Extra lines to be added verbatim to pdns.conf.
          Powerdns will chroot to /var/lib/powerdns.
          So any file, powerdns is supposed to be read,
          should be in /var/lib/powerdns and needs to specified
          relative to the chroot.
        '';
      };
    };
  };

  config = mkIf config.services.powerdns.enable {
    systemd.services.pdns = {
      unitConfig.Documentation = "man:pdns_server(1) man:pdns_control(1)";
      description = "Powerdns name server";
      wantedBy = [ "multi-user.target" ];
      after = ["network.target" "mysql.service" "postgresql.service" "openldap.service"];

      serviceConfig = {
        Restart="on-failure";
        RestartSec="1";
        StartLimitInterval="0";
        PrivateDevices=true;
        CapabilityBoundingSet="CAP_CHOWN CAP_NET_BIND_SERVICE CAP_SETGID CAP_SETUID CAP_SYS_CHROOT";
        NoNewPrivileges=true;
        ExecStart = "${pkgs.powerdns}/bin/pdns_server --chroot=${libDir} --socket-dir=/run --daemon=no --guardian=no --disable-syslog --write-pid=no --config-dir=${configDir}";
        ProtectSystem = "strict";
        ProtectHome = "tmpfs";
        RestrictAddressFamilies="AF_UNIX AF_INET AF_INET6";
        StateDirectory = "powerdns";
        DynamicUser = true;
      };
    };
  };
}
