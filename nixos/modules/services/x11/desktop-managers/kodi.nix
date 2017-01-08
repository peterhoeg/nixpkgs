{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xserver.desktopManager.kodi;

  bin = "${getBin pkgs.kodi}/bin/kodi --lircdev /run/lirc/lircd --standalone";

  advCfg = pkgs.writeText "advancedsettings.xml" ''
    <?xml version='1.0' encoding='utf-8'?>
    <advancedsettings>
      ${optionalString (cfg.database.type == "mysql") ''
      <videodatabase>
        <type>mysql</type>
        <host>${cfg.database.host}</host>
        <port>${toString cfg.database.port}</port>
        <user>${cfg.database.user}</user>
        <pass>${cfg.database.pass}</pass>
      </videodatabase>
      <musicdatabase>
        <type>mysql</type>
        <host>${cfg.database.host}</host>
        <port>${toString cfg.database.port}</port>
        <user>${cfg.database.user}</user>
        <pass>${cfg.database.pass}</pass>
      ''}
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
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      ln -s ${advCfg} $out/advancedsettings.xml
      ln -s ${srcCfg} $out/sources.xml
    '';
  };

  setupScript = pkgs.writeScript "handle_kodi_config.sh" ''
    processUserFile() {
      local userdata=${cfg.homeDir}/.kodi/userdata

      test -f $userdata/$1 && mv $userdata/$1 $userdata/$1.$(date +%s)
      ln -sf ${cfgDir}/$1 $userdata/$1
    }

    if [ "x${toString cfg.manageSources}" == "xtrue" ] ; then
      processUserFile sources.xml
    fi

    if [ "x${toString cfg.manageAdvanced}" == "xtrue" ] ; then
      processUserFile advancedsettings.xml
    fi
  '';

  # sddm is broken for auto-login using id < 1000
  uid = 3000; # config.ids.uids.kodi;

in {
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

      database = mkOption {
        default = {};
        description = "Configure the database.";
        type = (types.submodule {
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

            pass = mkOption {
              default = "kodi";
              type = types.str;
              description = "Database password.";
            };
          };
        });
      };

      manageSources = mkOption {
        type = types.bool;
        default = false;
        description = "Manage sources.xml from NixOS";
      };

      sourcesConfig = mkOption {
        type = types.str;
        default = null;
        description = ''sources.xml configuration'';
      };

      manageAdvanced = mkOption {
        type = types.bool;
        default = false;
        description = "Manage advancedsettings.xml from NixOS";
      };

      advancedConfig = mkOption {
        type = types.str;
        default = null;
        description = ''Extra advancedsettings.xml configuration'';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc.kodi.source = cfgDir;

    services.xserver = {
      desktopManager.session = [{
        name = "kodi";
        start = ''
          ${setupScript}
          ${bin} &
          waitPID=$!
        '';
      }];

      displayManager.sddm = mkIf (cfg.runMode == "auto-login") {
        enable = true;
        autoLogin = {
          enable = true;
          user = "kodi";
          relogin = true;
        };
      };
    };

    systemd.services = {
      kodi = {
        description = "Kodi Media Server on ${cfg.tty}";
        conflicts = [ "getty@${cfg.tty}.service"];
        after = [ "network.target" "sound.target" "mysqld.service" ];
        wants = [ "network.target" "sound.target" ];
        wantedBy = mkIf (cfg.runMode == "standalone" ) [ "multi-user.target" ];
        path = [ "${getBin pkgs.xorg.xorgserver}" ];
        serviceConfig = {
          User = "kodi";
          Group = "kodi";
          PAMName = "login";
          ExecStartPre = setupScript;
          ExecStart = ''
            ${pkgs.xorg.xinit}/bin/xinit ${bin} --standalone -- :${toString (if builtins.isInt config.services.xserver.display then config.services.xserver.display else 0)} -nolisten tcp ${builtins.replaceStrings [ "tty" ] [ "vt" ] cfg.tty}
          '';
          Restart = "on-failure";
          ProtectHome = true;
          ProtectSystem = "full";
          PrivateTmp = true;
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
      };
    };
  };
}
