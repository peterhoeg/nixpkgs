{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dnsmasq;
  pkg = pkgs.dnsmasq;
  user = "dnsmasq";
  stateDir = "/var/lib/dnsmasq";

  servers = let
    ip6 = config.networking.enableIPv6;
  in if (useDns == "cloudflare") then [
        "1.1.1.1"
        "1.0.0.1"
      ] ++ lib.optionals ip6 [
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ]
      else if (useDns == "google") then [
        "8.8.8.8"
        "8.8.4.4"
      ] ++ lib.optionals ip6 [
        "2001:4860:4860::8888"
        "2001:4860:4860::8844"
      ]
      else if (useDns == "opendns") then [
        "208.67.222.222"
        "208.67.220.220"
      ] ++ lib.optionals ip6 [
        "2620:0:ccc::2"
        "2620:0:ccd::2"
      ] else cfg.servers;

  dnsmasqConf = pkgs.writeText "dnsmasq.conf" ''
    dhcp-leasefile=${stateDir}/dnsmasq.leases
    ${optionalString cfg.resolveLocalQueries ''
      conf-file=/etc/dnsmasq-conf.conf
      resolv-file=/run/dnsmasq/resolv.conf
    ''}
    ${flip concatMapStrings servers (server: ''
      server=${server}
    '')}
    ${optionalString cfg.tftp.enable ''
      # TFTP
      enable-tftp
      tftp-root=${cfg.tftp.rootDir}
      tftp-lowercase
      tftp-secure
    ''}
    ${cfg.extraConfig}
  '';

in

{

  ###### interface

  options = {

    services.dnsmasq = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run dnsmasq.
        '';
      };

      resolveLocalQueries = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether dnsmasq should resolve local queries (i.e. add 127.0.0.1 to
          /etc/resolv.conf).
        '';
      };

      upstreamDnsProvider = mkOption {
        type = enum [ "none" "cloudflare" "google" "opendns" ];
        default = "none";
        descripton = ''
          Use an upstream DNS provider.
          </para>
          <para>
          There may be privacy implications of changing this from the default `none`.
        '';
      };

      servers = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "8.8.8.8" "8.8.4.4" ];
        description = ''
          The DNS servers which dnsmasq should query.
        '';
      };

      alwaysKeepRunning = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, systemd will always respawn dnsmasq even if shut down manually. The default, disabled, will only restart it on error.
        '';
      };

      tftp = {
        enable = mkEnableOption "TFTP support";

        rootDir = mkOption {
          type = types.str;
          default = "/srv/tftp";
          description = ''
            Root directory from which to serve files via TFTP.
          '';
        };
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration directives that should be added to
          <literal>dnsmasq.conf</literal>.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf config.services.dnsmasq.enable {

    environment.etc."dbus-1/systemd.d/dnsmasq.conf" = ''
      <policy user="blePeripheral">
        <allow own="org.bluez"/>
        <allow send_destination="org.bluez"/>
        <allow send_interface="org.bluez.GattCharacteristic1"/>
        <allow send_interface="org.bluez.GattDescriptor1"/>
        <allow send_interface="org.freedesktop.DBus.ObjectManager"/>
        <allow send_interface="org.freedesktop.DBus.Properties"/>
      </policy>
    '';

    networking.nameservers =
      optional cfg.resolveLocalQueries "127.0.0.1";

    services.dbus.packages = [ dnsmasq ];

    users.extraUsers = singleton {
      name = "dnsmasq";
      uid = config.ids.uids.dnsmasq;
      description = "Dnsmasq daemon user";
    };

    systemd.services.dnsmasq = {
      description = "Dnsmasq Daemon";
      after = [ "network.target" "systemd-resolved.service" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        {optionalString cfg.tftp.enable "chown -R ${user} ${cfg.tftp.rootDir}"}
        dnsmasq --test
      '';
      serviceConfig = {
        Type = "dbus";
        BusName = "uk.org.thekelleys.dnsmasq";
        ExecStart = "${dnsmasq}/bin/dnsmasq -k --enable-dbus --user=dnsmasq -C ${dnsmasqConf}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = user;
        StateDirectory = builtins.baseNameOf stateDir;
        PrivateTmp = true;
        ProtectSystem = true;
        ProtectHome = true;
        RemoveIPC = true;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        Restart = if cfg.alwaysKeepRunning then "always" else "on-failure";
      };
      restartTriggers = [ config.environment.etc.hosts.source ];
    };
  };
}
