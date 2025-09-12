{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.cage;
in
{
  options.services.cage = with lib.types; {
    enable = lib.mkEnableOption "cage kiosk service";

    tty = lib.mkOption {
      type = types.str;
      default = "tty1";
      description = ''
        The TTY on which to run.
      '';
    };

    user = lib.mkOption {
      type = types.str;
      default = "demo";
      description = ''
        User to log-in as.
      '';
    };

    extraArguments = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      defaultText = lib.literalExpression "[]";
      description = "Additional command line arguments to pass to Cage.";
      example = [ "-d" ];
    };

    environment = lib.mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        WLR_LIBINPUT_NO_DEVICES = "1";
      };
      description = "Additional environment variables to pass to Cage.";
    };

    program = lib.mkOption {
      type = types.path;
      default = "${pkgs.xterm}/bin/xterm";
      defaultText = lib.literalExpression ''"''${pkgs.xterm}/bin/xterm"'';
      description = ''
        Program to run in cage.
      '';
    };

    package = lib.mkPackageOption pkgs "cage" { };
  };

  config = lib.mkIf cfg.enable {

    # The service is partially based off of the one provided in the
    # cage wiki at
    # https://github.com/Hjdskes/cage/wiki/Starting-Cage-on-boot-with-systemd.
    systemd = {
      services."cage-${cfg.tty}" = {
        enable = true;
        after = [
          "systemd-user-sessions.service"
          "plymouth-start.service"
          "plymouth-quit.service"
          "systemd-logind.service"
          "getty@${cfg.tty}.service"
        ];
        before = [ "graphical.target" ];
        wants = [
          "dbus.socket"
          "systemd-logind.service"
          "plymouth-quit.service"
        ];
        wantedBy = [ "graphical.target" ];
        conflicts = [ "getty@${cfg.tty}.service" ];

        restartIfChanged = false;
        unitConfig.ConditionPathExists = "/dev/${cfg.tty}";
        serviceConfig = {
          ExecStart = lib.concatStringsSep " " [
            (lib.getExe cfg.package)
            (lib.escapeShellArgs cfg.extraArguments)
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
        inherit (cfg) environment;
      };

      targets.graphical.wants = [ "cage-tty1.service" ];

      defaultUnit = "graphical.target";
    };

    security.polkit.enable = true;

    security.pam.services.cage.text = ''
      auth    required pam_unix.so nullok
      account required pam_unix.so
      session required pam_unix.so
      session required pam_env.so conffile=/etc/pam/environment readenv=0
      session required ${config.systemd.package}/lib/security/pam_systemd.so
    '';

    hardware.graphics.enable = lib.mkDefault true;
  };

  meta.maintainers = with lib.maintainers; [ matthewbauer ];
}
