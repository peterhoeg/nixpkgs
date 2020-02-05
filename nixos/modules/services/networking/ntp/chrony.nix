{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.chrony;

  stateDir = "/var/lib/chrony";
  keyFile = "${stateDir}/chrony.keys";

  configFile = pkgs.writeText "chrony.conf" ''
    ${concatMapStringsSep "\n" (server: "server ${server} iburst") cfg.servers}

    ${optionalString (cfg.initstepslew.enabled && (cfg.servers != []))
      "initstepslew ${toString cfg.initstepslew.threshold} ${concatStringsSep " " cfg.servers}"
    }

    driftfile ${stateDir}/chrony.drift
    keyfile ${keyFile}
    dumpdir ${stateDir}

    ${optionalString (!config.time.hardwareClockInLocalTime) "rtconutc"}

    ${optionalString cfg.serverMode (lib.concatMapStringsSep "\n" (subnet:
      "allow ${subnet}"
    ) cfg.allowClientsFrom)}

    ${cfg.extraConfig}
  '';

  chronyFlags = "-n -m -u chrony -f ${configFile} ${toString cfg.extraFlags}";

in
{
  options = {
    services.chrony = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to synchronise your machine's time using chrony.Make sure you disable NTP if you enable this service.
        '';
      };

      servers = mkOption {
        default = config.networking.timeServers;
        description = ''
          The set of NTP servers from which to synchronise.
        '';
      };

      initstepslew = mkOption {
        default = {
          enabled = true;
          threshold = 1000; # by default, same threshold as 'ntpd -g' (1000s)
        };
        description = ''
          Allow chronyd to make a rapid measurement of the system clock error at
          boot time, and to correct the system clock by stepping before normal
          operation begins.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration directives that should be added to
          <literal>chrony.conf</literal>
        '';
      };

      extraFlags = mkOption {
        default = [];
        example = [ "-s" ];
        type = types.listOf types.str;
        description = "Extra flags passed to the chronyd command.";
      };

      serverMode = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Run chrony in server mode.
        '';
      };

      openFirewall = mkOption {
        default = config.services.chrony.serverMode;
        type = types.bool;
        description = ''
          Automatically allow the traffic through the firewall when running an NTP server.
        '';
      };

      allowClientsFrom = mkOption {
        default = [ "" ];
        example = [ "1.2.3.4/17" ];
        type = types.listOf types.str;
        description = ''
          Subnets from which to allow clients to connect. Default is everywhere.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    meta.maintainers = with lib.maintainers; [ thoughtpolice peterhoeg ];

    environment.systemPackages = with pkgs; [ chrony ];

    networking.firewall.allowedUdpPorts = lib.mkIf cfg.openFirewall [ 123 ];

    services.timesyncd.enable = mkForce false;

    systemd.services = {
      systemd-timedated.environment = { SYSTEMD_TIMEDATED_NTP_SERVICES = "chronyd.service"; };

      chronyd = {
        description = "chrony NTP daemon";

        wantedBy = [ "multi-user.target" ];
        wants = [ "time-sync.target" ];
        before = [ "time-sync.target" ];
        after = [ "network.target" ];
        conflicts = [ "ntpd.service" "systemd-timesyncd.service" ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.chrony}/bin/chronyd ${chronyFlags}";

          DynamicUser = true;
          ProtectHome = "tmpfs";
          ProtectSystem = "strict";

          AmbientCapabilities = [
            "CAP_NET_BIND_SERVICE"
            "CAP_SYS_TIME"
          ];

          StateDirectory = "chrony";
        };
      };
    };
  };
}
