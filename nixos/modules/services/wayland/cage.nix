{ config, pkgs, lib, ... }:

let
  cfg = config.services.cage;

  inherit (lib)
    concatStringsSep escapeShellArgs getExe
    literalExpression mdDoc mkDefault mkEnableOption mkOption mkIf types;

in
{
  meta.maintainers = with lib.maintainers; [ matthewbauer ];

  options.services.cage = {
    enable = mkEnableOption (mdDoc "cage kiosk service");

    tty = mkOption {
      type = types.str;
      default = "tty1";
      description = mdDoc ''
        The TTY on which to run.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "demo";
      description = mdDoc ''
        User to log-in as.
      '';
    };

    extraArguments = mkOption {
      type = types.listOf types.str;
      default = [ ];
      defaultText = literalExpression "[]";
      description = mdDoc "Additional command line arguments to pass to Cage.";
      example = [ "-d" ];
    };

    program = mkOption {
      type = types.path;
      default = "${pkgs.xterm}/bin/xterm";
      defaultText = literalExpression ''"''${pkgs.xterm}/bin/xterm"'';
      description = mdDoc ''
        Program to run in cage.
      '';
    };
  };

  config = mkIf cfg.enable {
    # The service is partially based off of the one provided in the
    # cage wiki at
    # https://github.com/Hjdskes/cage/wiki/Starting-Cage-on-boot-with-systemd.
    systemd.services."cage-${cfg.tty}" = {
      enable = true;
      after = [
        "systemd-user-sessions.service"
        "plymouth-start.service"
        "plymouth-quit.service"
        "systemd-logind.service"
        "getty@${cfg.tty}.service"
      ];
      before = [ "graphical.target" ];
      wants = [ "dbus.socket" "systemd-logind.service" "plymouth-quit.service" ];
      wantedBy = [ "graphical.target" ];
      conflicts = [ "getty@${cfg.tty}.service" ];
      restartIfChanged = false;

      unitConfig.ConditionPathExists = "/dev/${cfg.tty}";

      serviceConfig = {
        ExecStart = concatStringsSep "\ \n" [
          (getExe pkgs.cage)
          (escapeShellArgs cfg.extraArguments)
          "--"
          cfg.program
        ];
        User = cfg.user;

        IgnoreSIGPIPE = "no";

        # Log this user with utmp, letting it show up with commands 'w' and
        # 'who'. This is needed since we replace (a)getty.
        UtmpIdentifier = "%n";
        UtmpMode = "user";
        # A virtual terminal is needed.
        TTYPath = "/dev/${cfg.tty}";
        TTYReset = "yes";
        TTYVHangup = "yes";
        TTYVTDisallocate = "yes";
        # Fail to start if not controlling the virtual terminal.
        StandardInput = "tty-fail";
        StandardOutput = "journal";
        StandardError = "journal";
        # Set up a full (custom) user session for the user, required by Cage.
        PAMName = "cage";
      };
    };

    security.polkit.enable = true;

    security.pam.services.cage.text = ''
      auth    required pam_unix.so nullok
      account required pam_unix.so
      session required pam_unix.so
      session required pam_env.so conffile=/etc/pam/environment readenv=0
      session required ${config.systemd.package}/lib/security/pam_systemd.so
    '';

    hardware.opengl.enable = mkDefault true;

    systemd.targets.graphical.wants = [ "cage-${cfg.tty}.service" ];

    systemd.defaultUnit = "graphical.target";
  };
}
