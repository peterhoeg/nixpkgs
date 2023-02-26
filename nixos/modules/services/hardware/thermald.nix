{ config, lib, pkgs, ... }:

let
  cfg = config.services.thermald;

  inherit (lib)
    literalExpression mkEnableOption mkIf mkOption types
    concatStringsSep optional;

in
{
  ###### interface
  options.services.thermald = {
    enable = mkEnableOption (lib.mdDoc "thermald, the temperature management daemon");

    debug = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to enable debug logging.
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = lib.mdDoc "the thermald manual configuration file.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.thermald;
      defaultText = literalExpression "pkgs.thermald";
      description = lib.mdDoc "Which thermald package to use.";
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    services.dbus.packages = [ cfg.package ];

    systemd.services.thermald = {
      description = "Thermal Daemon Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        PrivateNetwork = true;
        PrivateTmp = true;
        ExecStart = concatStringsSep " " ([
          "${cfg.package}/sbin/thermald"
          "--adaptive"
          "--dbus-enable"
          "--systemd"
        ]
        ++ optional cfg.debug "--loglevel=debug"
        ++ optional (cfg.configFile != null) cfg.configFile
        );
      };
    };
  };
}
