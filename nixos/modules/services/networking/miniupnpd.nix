{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.miniupnpd;

  chain = "MINIUPNPD";

  boolToStr = bool: if bool then "yes" else "no";

  configFile = pkgs.writeText "miniupnpd.conf" ''
    ext_ifname=${cfg.externalInterface}
    enable_natpmp=${boolToStr cfg.natpmp}
    enable_upnp=${boolToStr cfg.upnp}
    secure_mode=${boolToStr cfg.secureMode}
    lease_file=/var/lib/miniupnpd/upnp.leases

    ${concatMapStrings (range: ''
      listening_ip=${range}
    '') cfg.internalIPs}

    ${cfg.appendConfig}
  '';
in
{
  options = {
    services.miniupnpd = with types; {
      enable = mkEnableOption "MiniUPnP daemon";

      externalInterface = mkOption {
        type = str;
        description = ''
          Name of the external interface.
        '';
      };

      internalIPs = mkOption {
        type = listOf str;
        example = [ "192.168.1.1/24" "enp1s0" ];
        description = ''
          The IP address ranges to listen on.
        '';
      };

      secureMode = mkOption {
        type = bool;
        default = true;
        description = ''
          Secure mode where a device can only set up mappings for its own IP address.
        '';
      };

      natpmp = mkEnableOption "NAT-PMP support";

      upnp = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Whether to enable UPNP support.
        '';
      };

      appendConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Configuration lines appended to the MiniUPnP config.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # from miniupnpd/netfilter/iptables_init.sh
    networking.firewall.extraCommands = ''
      iptables -t nat      -N ${chain} || true
      iptables -t nat      -A PREROUTING -i ${cfg.externalInterface}                               -j ${chain}
      iptables -t mangle   -N ${chain} || true
      iptables -t mangle   -A PREROUTING -i ${cfg.externalInterface}                               -j ${chain}
      ip46tables -t filter -N ${chain} || true
      ip46tables -t filter -A FORWARD    -i ${cfg.externalInterface} ! -o ${cfg.externalInterface} -j ${chain}
      iptables -t nat      -N ${chain}-PCP-PEER || true
      iptables -t nat      -A POSTROUTING                              -o ${cfg.externalInterface} -j ${chain}-PCP-PEER
    '';

    # from miniupnpd/netfilter/iptables_removeall.sh
    networking.firewall.extraStopCommands = ''
      iptables -t nat -F ${chain}
      iptables -t nat -D PREROUTING     -i ${cfg.externalInterface}                               -j ${chain}
      iptables -t nat -X ${chain}
      iptables -t mangle -F ${chain}
      iptables -t mangle -D PREROUTING  -i ${cfg.externalInterface}                               -j ${chain}
      iptables -t mangle -X ${chain}
      ip46tables -t filter -F ${chain}
      ip46tables -t filter -D FORWARD   -i ${cfg.externalInterface} ! -o ${cfg.externalInterface} -j ${chain}
      ip46tables -t filter -X ${chain}
      iptables -t nat -F ${chain}-PCP-PEER
      iptables -t nat -D POSTROUTING                                  -o ${cfg.externalInterface} -j ${chain}-PCP-PEER
      iptables -t nat -X ${chain}-PCP-PEER
    '';

    systemd.services.miniupnpd = {
      description = "MiniUPnP daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        CapabilityBoundingSet = "CAP_NET_RAW CAP_NET_ADMIN";
        StateDirectory = "miniupnpd";
        Type = "forking";
        ExecStart = "${pkgs.miniupnpd}/bin/miniupnpd -f ${configFile}";
        PIDFile = "/run/miniupnpd.pid";
      };
    };
  };
}
