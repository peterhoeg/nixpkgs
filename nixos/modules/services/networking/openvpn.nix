{ config, lib, pkgs, ... }:

let
  cfg = config.services.openvpn;

  inherit (lib)
    literalExpression mkIf mkOption mkRemovedOptionModule types
    getExe
    getAttr listToAttrs makeBinPath mapAttrsFlatten nameValuePair
    optional optionalAttrs optionalString;

  makeOpenVPNJob = cfg: name:
    let
      path = makeBinPath (getAttr "openvpn-${name}" config.systemd.services).path;

      upScript = ''
        #!${pkgs.runtimeShell}
        export PATH=${path}

        # For convenience in client scripts, extract the remote domain
        # name and name server.
        for var in ''${!foreign_option_*}; do
          x=(''${!var})
          if [ "''${x[0]}" = dhcp-option ]; then
            if [ "''${x[1]}" = DOMAIN ]; then domain="''${x[2]}"
            elif [ "''${x[1]}" = DNS ]; then nameserver="''${x[2]}"
            fi
          fi
        done

        ${cfg.up}
        ${optionalString cfg.updateResolvConf
           "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"}
      '';

      downScript = ''
        #!${pkgs.runtimeShell}
        export PATH=${path}
        ${optionalString cfg.updateResolvConf
           "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"}
        ${cfg.down}
      '';

      configFile = pkgs.writeText "openvpn-config-${name}" ''
        errors-to-stderr
        ${optionalString (cfg.up != "" || cfg.down != "" || cfg.updateResolvConf) "script-security 2"}
        ${cfg.config}
        ${optionalString (cfg.up != "" || cfg.updateResolvConf)
            "up ${pkgs.writeScript "openvpn-${name}-up" upScript}"}
        ${optionalString (cfg.down != "" || cfg.updateResolvConf)
            "down ${pkgs.writeScript "openvpn-${name}-down" downScript}"}
        ${optionalString (cfg.authUserPass != null)
            "auth-user-pass ${pkgs.writeText "openvpn-credentials-${name}" ''
              ${cfg.authUserPass.username}
              ${cfg.authUserPass.password}
            ''}"}
      '';

    in
    {
      description = "OpenVPN instance ‘${name}’";

      wantedBy = optional cfg.autoStart "openvpn.target";
      after = [ "network.target" ];

      path = with pkgs; [ iptables iproute2 nettools ];

      serviceConfig = {
        ExecStart = "@${getExe pkgs.openvpn} openvpn --suppress-timestamps --config ${configFile}";
        Restart = "always";
        Type = "notify";
        RuntimeDirectory = "openvpn";
        StateDirectory = "openvpn";
        Slice = "openvpn.slice";
      };
    };

in

{
  imports = [
    (mkRemovedOptionModule [ "services" "openvpn" "enable" ] "")
  ];

  ###### interface

  options.services.openvpn = {
    enableForwarding = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Set up IP forwarding on the host.
      '';
    };

    servers = mkOption {
      default = { };

      example = literalExpression ''
        {
          server = {
            config = '''
              # Simplest server configuration: https://community.openvpn.net/openvpn/wiki/StaticKeyMiniHowto
              # server :
              dev tun
              ifconfig 10.8.0.1 10.8.0.2
              secret /root/static.key
            ''';
            up = "ip route add ...";
            down = "ip route del ...";
          };

          client = {
            config = '''
              client
              remote vpn.example.org
              dev tun
              proto tcp-client
              port 8080
              ca /root/.vpn/ca.crt
              cert /root/.vpn/alice.crt
              key /root/.vpn/alice.key
            ''';
            up = "echo nameserver $nameserver | ''${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
            down = "''${pkgs.openresolv}/sbin/resolvconf -d $dev";
          };
        }
      '';

      description = lib.mdDoc ''
        Each attribute of this option defines a systemd service that
        runs an OpenVPN instance.  These can be OpenVPN servers or
        clients.  The name of each systemd service is
        `openvpn-«name».service`,
        where «name» is the corresponding
        attribute name.
      '';

      type = with types; attrsOf (submodule {

        options = {

          config = mkOption {
            type = types.lines;
            description = lib.mdDoc ''
              Configuration of this OpenVPN instance.  See
              {manpage}`openvpn(8)`
              for details.

              To import an external config file, use the following definition:
              `config = "config /path/to/config.ovpn"`
            '';
          };

          up = mkOption {
            default = "";
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands executed when the instance is starting.
            '';
          };

          down = mkOption {
            default = "";
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands executed when the instance is shutting down.
            '';
          };

          autoStart = mkOption {
            default = true;
            type = types.bool;
            description = lib.mdDoc "Whether this OpenVPN instance should be started automatically.";
          };

          updateResolvConf = mkOption {
            default = false;
            type = types.bool;
            description = lib.mdDoc ''
              Use the script from the update-resolv-conf package to automatically
              update resolv.conf with the DNS information provided by openvpn. The
              script will be run after the "up" commands and before the "down" commands.
            '';
          };

          authUserPass = mkOption {
            default = null;
            description = lib.mdDoc ''
              This option can be used to store the username / password credentials
              with the "auth-user-pass" authentication method.

              WARNING: Using this option will put the credentials WORLD-READABLE in the Nix store!
            '';
            type = types.nullOr (types.submodule {

              options = {
                username = mkOption {
                  description = lib.mdDoc "The username to store inside the credentials file.";
                  type = types.str;
                };

                password = mkOption {
                  description = lib.mdDoc "The password to store inside the credentials file.";
                  type = types.str;
                };
              };
            });
          };
        };
      });
    };

    restartAfterSleep = mkOption {
      default = true;
      type = types.bool;
      description = lib.mdDoc "Whether OpenVPN client should be restarted after sleep.";
    };
  };

  ###### implementation

  config = mkIf (cfg.servers != { }) {

    systemd.services = (listToAttrs (mapAttrsFlatten (name: value: nameValuePair "openvpn-${name}" (makeOpenVPNJob value name)) cfg.servers))
      // optionalAttrs cfg.restartAfterSleep {
      openvpn-restart = {
        wantedBy = [ "sleep.target" ];
        path = [ pkgs.procps ];
        script = "pkill --signal SIGHUP --exact openvpn";
        #SIGHUP makes openvpn process to self-exit and then it got restarted by systemd because of Restart=always
        description = "Sends a signal to OpenVPN process to trigger a restart after return from sleep";
      };
    };

    systemd.targets.openvpn = {
      description = "OpenVPN instances";
      wantedBy = [ "multi-user.target" ];
    };

    environment.systemPackages = [ pkgs.openvpn ];

    boot.kernelModules = [ "tun" ];

    boot.kernel.sysctl = lib.mkIf cfg.enableForwarding ({
      "net.ipv4.ip_forward" = true;
    } // (lib.optionalAttrs config.networking.enableIPv6 {
      "net.ipv6.conf.all.forwarding" = true;
    }));

    users =
      let
        user = "openvpn";
      in
      {
        users."${user}" = {
          description = "OpenVPN";
          isNormalUser = false;
          group = user;
          uid = config.ids.uids."${user}";
        };

        groups."${user}".gid = config.ids.gids."${user}";
      };
  };
}
