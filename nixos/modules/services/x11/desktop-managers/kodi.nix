{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.desktopManager.kodi;

  bin = "${getBin pkgs.kodi}/bin/kodi --lircdev /run/lirc/lircd --standalone";

  boolToStr = bool: if bool then "true" else "false";

  manageSources = (cfg.sourcesConfig != "");

  advCfg = pkgs.writeText "advancedsettings.xml" ''
    <?xml version='1.0' encoding='utf-8'?>
    <advancedsettings>
      ${optionalString (cfg.database.type == "mysql") ''
    <videodatabase>
      <type>mysql</type>
      <host>${cfg.database.host}</host>
      <port>${toString cfg.database.port}</port>
      <user>${cfg.database.user}</user>
      <pass>${cfg.database.password}</pass>
    </videodatabase>
    <musicdatabase>
      <type>mysql</type>
      <host>${cfg.database.host}</host>
      <port>${toString cfg.database.port}</port>
      <user>${cfg.database.user}</user>
      <pass>${cfg.database.password}</pass>
    </musicdatabase>''}
      ${cfg.advancedConfig}
    </advancedsettings>
  '';

  srcCfg = pkgs.writeText "sources.xml" ''
    <?xml version='1.0' encoding='utf-8'?>
    <sources>
      ${cfg.sourcesConfig}
    </sources>
  '';

  cfgDir = pkgs.stdenv.mkDerivation {
    name = "kodi-config";
    buildCommand = ''
      dir=$out/etc/kodi
      mkdir -p $dir

      ln -s ${advCfg} $dir/advancedsettings.xml
      ln -s ${srcCfg} $dir/sources.xml
    '';
  };

  setupScript = pkgs.writeScript "link_kodi_config.sh" ''
    #!${pkgs.runtimeShell}
    set -eEuo pipefail

    processUserFile() {
      local userdata=${cfg.homeDir}/.kodi/userdata
      local file=$1
      local symlink=''${2:-1}

      test -f $userdata/$1 && mv $userdata/$1 $userdata/$1.$(date +%s)
      mkdir -p $userdata
      ln -sf ${cfgDir}/etc/kodi/$1 $userdata/$1
    }

    processUserFile advancedsettings.xml

    if [ "x${boolToStr manageSources}" == "xtrue" ] ; then
      processUserFile sources.xml
    fi

    exit 0
  '';

  # sddm is broken for auto-login using id < 1000
  # https://github.com/sddm/sddm/issues/762
  # uid = config.ids.uids.kodi;
  uid = 3000;

in
{
  options = {
    services.xserver.desktopManager.kodi = {
      enable = mkOption {
        default = false;
        type = types.bool;
        example = true;
        description = "Enable the kodi multimedia center.";
      };

      runMode = mkOption {
        default = "session";
        type = types.enum [ "session" "auto-login" "standalone" ];
        description = ''
          How to launch kodi.
        '';
      };

      tty = mkOption {
        default = "tty7";
        type = types.str;
        description = "Which TTY to launch kodi on.";
      };

      homeDir = mkOption {
        default = "/var/lib/kodi";
        type = types.str;
        description = "Home directory.";
      };

      zeroconf = mkOption {
        default = false;
        type = types.bool;
        description = "Enable support for Zeroconf/Avahi";
      };

      database = mkOption {
        default = {};
        description = "Configure the database.";
        type = (
          types.submodule {
            options = {
              type = mkOption {
                default = "sqlite";
                type = types.enum [ "sqlite" "mysql" ];
                description = "Which type of database to connect to.";
              };

              host = mkOption {
                default = "localhost";
                type = types.str;
                description = "Database host.";
              };

              port = mkOption {
                default = 3306;
                type = types.int;
                description = "Database port.";
              };

              user = mkOption {
                default = "kodi";
                type = types.str;
                description = "Database user.";
              };

              password = mkOption {
                default = "kodi";
                type = types.str;
                description = "Database password.";
              };
            };
          }
        );
      };

      sourcesConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''sources.xml configuration'';
      };

      advancedConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''Extra advancedsettings.xml configuration'';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc.kodi.source = cfgDir;

    services = {
      avahi.enable = cfg.zeroconf;

      xserver = {
        desktopManager.session = [
          {
            name = "kodi";
            start = ''
              ${setupScript}
              ${bin} &
              waitPID=$!
            '';
          }
        ];

        displayManager.sddm = {
          enable = (cfg.runMode == "auto-login");
          autoLogin = {
            enable = true;
            user = "kodi";
            relogin = true;
          };
        };
      };
    };

    systemd.services = {
      kodi = mkIf (cfg.runMode == "standalone") {
        description = "Kodi Media Server on ${cfg.tty}";
        conflicts = [ "getty@${cfg.tty}.service" ];
        after = [ "mysqld.service" ];
        wantedBy = [ "graphical.target" ];
        path = [ "${getBin pkgs.xorg.xorgserver}" ];
        serviceConfig = {
          User = "kodi";
          Group = "kodi";
          PAMName = "login";
          ExecStartPre = setupScript;
          ExecStart = lib.concatStringsSep " " [
            "${pkgs.xorg.xinit}/bin/xinit ${bin} -- :"
            (toString (if builtins.isInt config.services.xserver.display then config.services.xserver.display else 0))
            "-nolisten tcp"
            (builtins.replaceStrings [ "tty" ] [ "vt" ] cfg.tty)
          ];
          Restart = "on-failure";
          ProtectSystem = "full";
          # doesn't work with true as it is expecting a socket in /tmp
          PrivateTmp = false;
        };
      };
    };

    users = {
      extraGroups.kodi.gid = uid;

      extraUsers.kodi = {
        uid = uid;
        group = "kodi";
        home = cfg.homeDir;
        description = "Kodi User";
        createHome = true;
        shell = "${pkgs.stdenv.shell}";
        isNormalUser = false;
        # tty seems needed for "standalone" although not quite working yet
        extraGroups = [ "tty" ];
      };
    };
  };
}
