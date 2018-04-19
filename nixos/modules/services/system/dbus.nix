# D-Bus configuration and system bus daemon.

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.dbus;

  pkg = if cfg.useDbusBroker then dbus-broker else dbus.daemon;

  homeDir = "/run/dbus";

  configDir = pkgs.makeDBusConf {
    suidHelper = "${config.security.wrapperDir}/dbus-daemon-launch-helper";
    serviceDirectories = cfg.packages;
  };

in

{

  ###### interface

  options = {

    services.dbus = {

      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Whether to start the D-Bus message bus daemon, which is
          required by many other system services and applications.
        '';
      };

      useDbusBroker = mkOption {
        type = types.bool;
        default = false;
        description  = ''
          Use the new dbus-broker instead of the legacy reference implementation.
        '';
      };

      packages = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          Packages whose D-Bus configuration files should be included in
          the configuration of the D-Bus system-wide or session-wide
          message bus.  Specifically, files in the following directories
          will be included into their respective DBus configuration paths:
          <filename><replaceable>pkg</replaceable>/etc/dbus-1/system.d</filename>
          <filename><replaceable>pkg</replaceable>/share/dbus-1/system-services</filename>
          <filename><replaceable>pkg</replaceable>/etc/dbus-1/session.d</filename>
          <filename><replaceable>pkg</replaceable>/share/dbus-1/services</filename>
        '';
      };

      socketActivated = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Make the user instance socket activated.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = (with pkgs; [ dbus ] ++ ([ pkg ]));

    environment.etc = singleton
      { source = configDir;
        target = "dbus-1";
      };

    users.extraUsers.messagebus = {
      uid = config.ids.uids.messagebus;
      description = "D-Bus system message bus daemon user";
      home = homeDir;
      group = "messagebus";
    };

    users.extraGroups.messagebus.gid = config.ids.gids.messagebus;

    systemd.packages = [ pkg ];

    security.wrappers.dbus-daemon-launch-helper = {
      source = "${pkgs.dbus.daemon}/libexec/dbus-daemon-launch-helper";
      owner = "root";
      group = "messagebus";
      setuid = true;
      setgid = false;
      permissions = "u+rx,g+rx,o-rx";
    };

    services.dbus.packages = [
      pkgs.dbus.out
      config.system.path
    ];

    systemd.services.dbus = {
      # Don't restart dbus-daemon. Bad things tend to happen if we do.
      reloadIfChanged = true;
      restartTriggers = [ configDir ];
    };

    systemd.user = {
      services.dbus = {
        # Don't restart dbus-daemon. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [ configDir ];
      };
      sockets.dbus.wantedBy = mkIf cfg.socketActivated [ "sockets.target" ];
    };

    environment.pathsToLink = [ "/etc/dbus-1" "/share/dbus-1" ];
  };
}
