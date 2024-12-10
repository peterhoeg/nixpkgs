{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  CONTAINS_NEWLINE_RE = ".*\n.*";
  # The following values are reserved as complete option values:
  # { - start of a group.
  # """ - start of a multi-line string.
  RESERVED_VALUE_RE = "[[:space:]]*(\"\"\"|\\{)[[:space:]]*";
  NEEDS_MULTILINE_RE = "${CONTAINS_NEWLINE_RE}|${RESERVED_VALUE_RE}";

  # There is no way to encode """ on its own line in a Minetest config.
  UNESCAPABLE_RE = ".*\n\"\"\"\n.*";

  dir = "/var/lib/minetest";

  toConfMultiline =
    name: value:
    assert lib.assertMsg (
      (builtins.match UNESCAPABLE_RE value) == null
    ) ''""" can't be on its own line in a minetest config.'';
    "${name} = \"\"\"\n${value}\n\"\"\"\n";

  toConf =
    values:
    lib.concatStrings (
      lib.mapAttrsToList (
        name: value:
        {
          bool = "${name} = ${toString value}\n";
          int = "${name} = ${toString value}\n";
          null = "";
          set = "${name} = {\n${toConf value}}\n";
          string =
            if (builtins.match NEEDS_MULTILINE_RE value) != null then
              toConfMultiline name value
            else
              "${name} = ${value}\n";
        }
        .${builtins.typeOf value}
      ) values
    );

  cfg = config.services.minetest-server;

  flags =
    let
      flag =
        val: name:
        lib.optionals (val != null) [
          "--${name}"
          "${toString val}"
        ];

      file =
        if cfg.configPath != null then
          cfg.configPath
        else
          (builtins.toFile "minetest.conf" (toConf cfg.config));
    in
    [
      "--config"
      file
    ]
    ++ (flag cfg.gameId "gameid")
    ++ (flag cfg.world "world")
    ++ (flag cfg.logPath "logfile")
    ++ (flag cfg.port "port")
    ++ cfg.extraArgs;

  addonsSetup =
    let
      collection = pkgs.symlinkJoin {
        name = "luanti-addons";
        paths = cfg.addons;
      };
    in
    pkgs.resholve.writeScriptBin "minetest-addons-setup"
      {
        interpreter = pkgs.runtimeShell;
        inputs = with pkgs; [
          coreutils
          findutils
        ];
        execer = map (e: "cannot:${if builtins.isString e then e else lib.getExe e}") [ ];
      }
      ''
        set -eEuo pipefail

        _copy() {
          local kind; kind="$1"
          local tgt=${dir}/.minetest/$kind

          test -d $tgt || mkdir -p $tgt

          for d in ${collection}/share/minetest/$kind/*; do
            base="$(basename "$d")"
            rm -rf "$tgt/$base"
            cp -R --dereference --no-preserve=all $d $tgt/
          done
        }

        _link() {
          local kind; kind="$1"
          local tgt=${dir}/.minetest/$kind

          test -d $tgt || mkdir -p $tgt

          find $tgt -maxdepth 1 -type l -delete
          ln -s ${collection}/share/minetest/$kind/* -t $tgt
        }

        for kind in games mods textures; do
          # we cannot symlink as that runs afoul of minetest's secure environment, but need to copy
          # the files into place

          _copy $kind
        done
      '';

in
{
  options = {
    services.minetest-server = {
      enable = mkEnableOption "start a Minetest Server.";

      package = mkPackageOption pkgs "minetestserver" { };

      gameId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Id of the game to use. To list available games run
          `minetestserver --gameid list`.

          If only one game exists, this option can be null.
        '';
      };

      world = mkOption {
        type = types.nullOr (
          types.oneOf [
            types.path
            types.str
          ]
        );
        default = null;
        description = ''
          Name of the world to use. To list available worlds run
          `minetestserver --world list`.

          If only one world exists, this option can be null.
        '';
      };

      configPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to the config to use.

          If set to null, the config of the running user will be used:
          `~/.minetest/minetest.conf`.
        '';
      };

      config = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = ''
          Settings to add to the minetest config file.

          This option is ignored if `configPath` is set.
        '';
      };

      logPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to logfile for logging.

          If set to null, logging will be output to stdout which means
          all output will be caught by systemd.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 30000;
        description = ''
          Port number to bind to.
        '';
      };

      addons = mkOption {
        type = types.listOf types.package;
        description = "Addons";
        default = [ ];
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Additional command line flags to pass to the minetest executable.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.minetest-server = {
      description = "Minetest Server Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment.HOME = dir;
      serviceConfig = {
        ExecStartPre = lib.getExe addonsSetup;
        ExecStart = "${lib.getExe cfg.package} ${lib.escapeShellArgs flags}";
        StateDirectory = builtins.baseNameOf dir;
        Restart = "always";
        RestartSec = "5s";
        DynamicUser = true;
        User = "minetest";
        Group = "minetest";
        PrivateTmp = true;
        ProtectHome = "tmpfs";
        ProtectSystem = "strict";
        SyslogIdentifier = "%N";
        WorkingDirectory = dir;
      };
    };
  };
}
