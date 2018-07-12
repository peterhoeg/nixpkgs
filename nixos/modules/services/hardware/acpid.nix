{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.acpid;

  canonicalHandlers = {
    powerEvent = {
      event = "button/power.*";
      action = config.services.acpid.powerEventCommands;
    };

    lidEvent = {
      event = "button/lid.*";
      action = config.services.acpid.lidEventCommands;
    };

    acEvent = {
      event = "ac_adapter.*";
      action = config.services.acpid.acEventCommands;
    };
  };

  acpiConfDir = pkgs.runCommand "acpi-events" {}
    ''
      mkdir -p $out
      ${
        # Generate a configuration file for each event. (You can't have
        # multiple events in one config file...)
        let f = name: handler:
          ''
            fn=$out/${name}
            echo "event=${handler.event}" > $fn
            echo "action=${pkgs.writeShellScriptBin "${name}.sh" handler.action }/bin/${name}.sh '%e'" >> $fn
          '';
        in concatStringsSep "\n" (mapAttrsToList f (canonicalHandlers // config.services.acpid.handlers))
      }
    '';

in

{

  ###### interface

  options = {

    services.acpid = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the ACPI daemon.";
      };

      socketActivation = mkOption {
        type = types.bool;
        default = true;
        description = "Only run acpid when connections are made to its socket.";
      };

      logEvents = mkOption {
        type = types.bool;
        default = false;
        description = "Log all event activity.";
      };

      handlers = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            event = mkOption {
              type = types.str;
              example = [ "button/power.*" "button/lid.*" "ac_adapter.*" "button/mute.*" "button/volumedown.*" "cd/play.*" "cd/next.*" ];
              description = "Event type.";
            };

            action = mkOption {
              type = types.lines;
              description = "Shell commands to execute when the event is triggered.";
            };
          };
        });

        description = ''
          Event handlers.

          <note><para>
            Handler can be a single command.
          </para></note>
        '';
        default = {};
        example = {
          ac-power = {
            event = "ac_adapter/*";
            action = ''
              vals=($1)  # space separated string to array of multiple values
              case ''${vals[3]} in
                  00000000)
                      echo unplugged >> /tmp/acpi.log
                      ;;
                  00000001)
                      echo plugged in >> /tmp/acpi.log
                      ;;
                  *)
                      echo unknown >> /tmp/acpi.log
                      ;;
              esac
            '';
          };
        };
      };

      powerEventCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Shell commands to execute on a button/power.* event.";
      };

      lidEventCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Shell commands to execute on a button/lid.* event.";
      };

      acEventCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Shell commands to execute on an ac_adapter.* event.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.acpid = rec {
      description = "ACPI Daemon";

      wantedBy = lib.mkIf (! cfg.socketActivation) [ "multi-user.target" ];
      requires = [ "acpid.socket" ];
      after = requires;

      serviceConfig = {
        ExecStart = "${pkgs.acpid}/bin/acpid --foreground --netlink ${optionalString cfg.logEvents "--logevents"} --confdir ${acpiConfDir} --nosocket";
      };

      unitConfig = {
        ConditionVirtualization = "!systemd-nspawn";
        ConditionPathExists = [ "/proc/acpi" ];
      };
    };

    systemd.sockets.acpid = {
      description = "ACPI Daemon";

      wantedBy = lib.mkIf cfg.socketActivation [ "sockets.target" ];

      socketConfig = {
        Accept = true;
        StandardInput = "socket";
        ListenStream = "/run/acpid.socket";
      };
    };
  };
}
