{ config, pkgs, lib, ... }:

let
  cfg = config.services.ddclient;
  dataDir = "/var/lib/ddclient";

  inherit (lib)
    concatStringsSep mapAttrsToList
    getAttrFromPath mkIf mkChangedOptionModule mkRemovedOptionModule
    optionalAttrs optionalString recursiveUpdate;

  configFile' = pkgs.writeText "ddclient.conf"
    (concatStringsSep "\n"
      (mapAttrsToList
        (n: v:
          if (v == null)
          then n
          else "${n}=${if builtins.isBool v then (if v then "YES" else "NO") else toString v}"
        )
        (recursiveUpdate
          ({
            "${concatStringsSep "," cfg.domains}" = null;
            cache = "${dataDir}/ddclient.cache";
            foreground = true;
            use = cfg.use;
            login = cfg.username;
            password = if cfg.protocol == "nsupdate" then "${dataDir}/ddclient.key" else "@password_placeholder@";
            wildcard = true;
            inherit (cfg) ipv6 protocol quiet ssl verbose;
          }
          // optionalAttrs (cfg.script != "") { inherit (cfg) script; }
          // optionalAttrs (cfg.server != "") { inherit (cfg) server; }
          // optionalAttrs (cfg.zone != "") { inherit (cfg) zone; }
          )
          cfg.settings)));

  configFile = if (cfg.configFile != null) then cfg.configFile else configFile';

  preStart = pkgs.writeShellScriptBin "ddclient-prestart" ''
    install ${configFile} ${dataDir}/ddclient.conf
    ${lib.optionalString (cfg.configFile == null)
      (if (cfg.protocol == "nsupdate") then ''
      install ${cfg.passwordFile} ${dataDir}/ddclient.key
    '' else if (cfg.passwordFile != null) then ''
      "${pkgs.replace-secret}/bin/replace-secret" "@password_placeholder@" "${cfg.passwordFile}" "${dataDir}/ddclient.conf"
    '' else ''
      sed -i '/^password=@password_placeholder@$/d' ${dataDir}/ddclient.conf
    '')}
  '';

in
{

  imports = [
    (mkChangedOptionModule [ "services" "ddclient" "domain" ] [ "services" "ddclient" "domains" ]
      (config:
        let value = getAttrFromPath [ "services" "ddclient" "domain" ] config;
        in if value != "" then [ value ] else [ ]))
    (mkRemovedOptionModule [ "services" "ddclient" "homeDir" ] "")
    (mkRemovedOptionModule [ "services" "ddclient" "extraConfig" ] "Use services.ddclient.settings instead.")
    (mkRemovedOptionModule [ "services" "ddclient" "password" ] "Use services.ddclient.passwordFile instead.")
  ];

  ###### interface

  options.services.ddclient = with lib.types; {
    enable = mkOption {
      default = false;
      type = bool;
      description = lib.mdDoc ''
        Whether to synchronise your machine's IP address with a dynamic DNS
        provider (e.g.dyndns.org).
      '';
    };

    package = mkOption {
      type = package;
      default = pkgs.ddclient;
      defaultText = "pkgs.ddclient";
      description = lib.mdDoc ''
        The ddclient executable package run by the service.
      '';
    };

    domains = mkOption {
      default = [ "" ];
      type = listOf str;
      description = lib.mdDoc ''
        Domain name (s) to synchronize.'';
    };

    username = mkOption {
      default = lib.optionalString (config.services.ddclient.protocol == "nsupdate") "${pkgs.bind.dnsutils}/bin/nsupdate";
      defaultText = "";
      type = str;
      description = lib.mdDoc ''
        User name.

        For `nsupdate`, username contains the path to the nsupdate executable
      '';
    };

    passwordFile = mkOption {
      default = null;
      type = nullOr str;
      description = lib.mdDoc ''
        A file containing the password or a TSIG key in named format when using
        the nsupdate protocol.
      '';
    };

    interval = mkOption {
      default = "10min";
      type = str;
      description = lib.mdDoc ''
        The interval at which to run the check and update.
        See {command}`man 7 systemd.time` for the format.
      '';
    };

    configFile = mkOption {
      default = null;
      type = nullOr path;
      description = lib.mdDoc ''
        Path to configuration file.
        When set this overrides the generated configuration from module options.
      '';
      example = "/root/nixos/secrets/ddclient.conf";
    };

    protocol = mkOption {
      default = "dyndns2";
      type = str;
      description = lib.mdDoc ''
        Protocol to use with dynamic DNS provider (see https://sourceforge.net/p/ddclient/wiki/protocols).
      '';
    };

    server = mkOption {
      default = "";
      type = str;
      description = lib.mdDoc ''
        Server address.
      '';
    };

    ssl = mkOption {
      default = true;
      type = bool;
      description = lib.mdDoc ''
        Whether to use SSL/TLS to connect to dynamic DNS provider.
      '';
    };

    ipv6 = mkOption {
      default = false;
      type = bool;
      description = lib.mdDoc ''
        Whether to use IPv6.
      '';
    };


    quiet = mkOption {
      default = false;
      type = bool;
      description = lib.mdDoc ''
        Print no messages for unnecessary updates.
      '';
    };

    script = mkOption {
      default = "";
      type = str;
      description = lib.mdDoc ''
        script as required by some providers.
      '';
    };

    use = mkOption {
      default = "web, web=checkip.dyndns.com/, web-skip='Current IP Address: '";
      type = str;
      description = lib.mdDoc ''
        Method to determine the IP address to send to the dynamic DNS provider.
      '';
    };

    verbose = mkOption {
      default = false;
      type = bool;
      description = lib.mdDoc ''
        Print verbose information.
      '';
    };

    zone = mkOption {
      default = "";
      type = str;
      description = lib.mdDoc ''
        zone as required by some providers.
      '';
    };

    settings = mkOption {
      default = { };
      type = attrs;
      description = lib.mdDoc ''
        Extra configuration. Contents will be merged into the configuration file.
      '';
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.ddclient = {
      description = "Dynamic DNS Client";
      after = [ "network.target" "nss-lookup.target" ];
      restartTriggers = [ configFile ];

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = builtins.baseNameOf dataDir;
        CacheDirectory = builtins.baseNameOf dataDir;
        Type = "oneshot";
        ExecStartPre = preStart;
        ExecStart = "${lib.getBin cfg.package}/bin/ddclient -file ${dataDir}/ddclient.conf";
        SyslogIdentifier = "%N";
      };
    };

    systemd.timers.ddclient = {
      description = "Run ddclient";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.interval;
        OnUnitInactiveSec = cfg.interval;
      };
    };
  };
}
