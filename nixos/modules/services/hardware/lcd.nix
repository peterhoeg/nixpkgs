{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption mkOption mkIf types
    mkRemovedOptionModule;

  cfg = config.services.hardware.lcd;
  pkg = lib.getBin pkgs.lcdproc;

  cfgFmt = pkgs.formats.ini { };

  serverCfg = cfgFmt.generate "lcdd.conf" (lib.recursiveUpdate
    {
      server = {
        DriverPath = "${pkg}/lib/lcdproc/";
        Bind = cfg.serverHost;
        Port = cfg.serverPort;
        ReportToSyslog = false;
      };
    }
    cfg.server.settings);

  clientCfg = cfgFmt.generate "lcdproc.conf" (lib.recursiveUpdate
    {
      lcdproc = {
        Server = cfg.serverHost;
        Port = cfg.serverPort;
        ReportToSyslog = false;
      };
    }
    cfg.client.settings);

  serviceCfg = attrs:
    lib.recursiveUpdate
      {
        wantedBy = [ "lcd.target" ];
        serviceConfig = {
          DynamicUser = true;
          Restart = "on-failure";
          Slice = "lcd.slice";
        };
      }
      attrs;

in
{
  meta.maintainers = with lib.maintainers; [ peterhoeg ];

  imports = [
    (mkRemovedOptionModule [ "services" "hardware" "lcd" "server" "extraConfig" ] "Use services.hardware.lcd.server.settings instead.")
    (mkRemovedOptionModule [ "services" "hardware" "lcd" "client" "extraConfig" ] "Use services.hardware.lcd.client.settings instead.")
  ];

  options = with types; {
    services.hardware.lcd = {
      serverHost = mkOption {
        type = str;
        default = "localhost";
        description = lib.mdDoc "Host on which LCDd is listening.";
      };

      serverPort = mkOption {
        type = int;
        default = 13666;
        description = lib.mdDoc "Port on which LCDd is listening.";
      };

      server = {
        enable = mkEnableOption (lib.mdDoc "LCD panel server (LCDd)");

        openPorts = mkOption {
          type = bool;
          default = false;
          description = lib.mdDoc "Open the ports in the firewall";
        };

        usb = {
          permissions = mkOption {
            type = bool;
            default = false;
            description = lib.mdDoc ''
              Set group-write permissions on a USB device.

              A USB connected LCD panel will most likely require having its
              permissions modified for lcdd to write to it. Enabling this option
              sets group-write permissions on the device identified by
              `services.hardware.lcd.usbVid` and `services.hardware.lcd.usbPid`.
              In order to find the values, you can run the `lsusb` command.
              Example output:
              ```
              Bus 005 Device 002: ID 0403:c630 Future Technology Devices International, Ltd lcd2usb interface
              ```

              In this case the vendor id is `0403` and the product id is `c630`.
            '';
          };

          vid = mkOption {
            type = str;
            description = lib.mdDoc "The vendor ID of the USB device to claim.";
          };

          pid = mkOption {
            type = str;
            description = lib.mdDoc "The product ID of the USB device to claim.";
          };

          group = mkOption {
            type = str;
            default = "dialout";
            description = lib.mdDoc "The group to grant write permissions on the USB device";
          };
        };

        settings = mkOption {
          type = cfgFmt.type;
          default = { };
          description = lib.mdDoc "Additional configuration added to the server config.";
        };
      };

      client = {
        enable = mkEnableOption (lib.mdDoc "LCD panel client (LCDproc)");

        restartForever = mkOption {
          type = bool;
          default = true;
          description = lib.mdDoc "Try restarting the client forever.";
        };

        settings = mkOption {
          type = cfgFmt.type;
          default = { };
          description = lib.mdDoc "Additional configuration added to the client config.";
        };
      };
    };
  };

  config = mkIf (cfg.server.enable || cfg.client.enable) {
    networking.firewall.allowedTCPPorts = mkIf (cfg.server.enable && cfg.server.openPorts) [ cfg.serverPort ];

    services.udev.extraRules = mkIf cfg.server.enable (lib.concatStringsSep ", " ([
      ''ACTION=="add"''
      ''SUBSYSTEMS=="usb"''
      ''ATTRS{idVendor}=="${cfg.server.usb.vid}"''
      ''ATTRS{idProduct}=="${cfg.server.usb.pid}"''
      ''SYMLINK="lcd"''
      ''TAG+="systemd"''
    ] ++ lib.optionals cfg.server.usb.permissions [
      ''MODE="0664"''
      ''GROUP="${cfg.server.usb.group}"''
    ]));

    systemd.services = {
      lcdd = mkIf cfg.server.enable (serviceCfg {
        description = "LCDproc - server";
        serviceConfig = {
          ExecStart = "${pkg}/bin/LCDd -f -c ${serverCfg}";
          SupplementaryGroups = mkIf cfg.server.usb.permissions [ cfg.server.usb.group ];
        };
      });

      lcdproc = mkIf cfg.client.enable (serviceCfg {
        description = "LCDproc - client";
        after = [ "lcdd.service" ];
        # Allow restarting for eternity
        startLimitIntervalSec = lib.mkIf cfg.client.restartForever 0;
        serviceConfig = {
          ExecStart = "${pkg}/bin/lcdproc -f -c ${clientCfg}";
          # If the server is being restarted at the same time, the client will
          # fail as it cannot connect, so space it out a bit.
          RestartSec = "5";
        };
      });
    };

    systemd.targets.lcd = {
      description = "LCD client/server";
      after = [ "lcdd.service" "lcdproc.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
