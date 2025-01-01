{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hardware.lcd;

  cfgFmt = pkgs.formats.ini { };

  serverCfg = cfgFmt.generate "lcdd.conf" (
    lib.recursiveUpdate {
      server = {
        DriverPath = "${lib.getBin pkgs.lcdproc}/lib/lcdproc/";
        Bind = cfg.serverHost;
        Port = cfg.serverPort;
        ReportToSyslog = false;
      };
    } cfg.server.settings
  );

  clientCfg = cfgFmt.generate "lcdproc.conf" (
    lib.recursiveUpdate {
      lcdproc = {
        Server = cfg.serverHost;
        Port = cfg.serverPort;
        ReportToSyslog = false;
      };
    } cfg.client.settings
  );

  serviceCfg =
    attrs:
    lib.recursiveUpdate {
      wantedBy = [ "lcd.target" ];
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        Slice = "lcd.slice";
      };
    } attrs;

in
{
  meta.maintainers = with lib.maintainers; [ peterhoeg ];

  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "hardware"
      "lcd"
      "server"
      "extraConfig"
    ] "Use services.hardware.lcd.server.settings instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "hardware"
      "lcd"
      "client"
      "extraConfig"
    ] "Use services.hardware.lcd.client.settings instead.")
    (lib.mkRenamedOptionModule
      [ "services" "hardware" "lcd" "usbPermissions" ]
      [ "services" "hardware" "lcd" "server" "usb" "permissions" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "hardware" "lcd" "usbVid" ]
      [ "services" "hardware" "lcd" "server" "usb" "vid" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "hardware" "lcd" "usbPid" ]
      [ "services" "hardware" "lcd" "server" "usb" "pid" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "hardware" "lcd" "usbGroup" ]
      [ "services" "hardware" "lcd" "server" "usb" "group" ]
    )
  ];

  options = with lib.types; {
    services.hardware.lcd = {
      serverHost = lib.mkOption {
        type = str;
        default = "localhost";
        description = "Host on which LCDd is listening.";
      };

      serverPort = lib.mkOption {
        type = int;
        default = 13666;
        description = "Port on which LCDd is listening.";
      };

      server = {
        enable = lib.mkEnableOption "LCD panel server (LCDd)";

        openPorts = lib.mkOption {
          type = bool;
          default = false;
          description = "Open the ports in the firewall";
        };

        usb = {
          permissions = lib.mkOption {
            type = bool;
            default = false;
            description = ''
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

          vid = lib.mkOption {
            type = str;
            description = "The vendor ID of the USB device to claim.";
          };

          pid = lib.mkOption {
            type = str;
            description = "The product ID of the USB device to claim.";
          };

          group = lib.mkOption {
            type = str;
            default = "dialout";
            description = "The group to grant write permissions on the USB device";
          };
        };

        settings = lib.mkOption {
          inherit (cfgFmt) type;
          default = { };
          description = "Additional configuration added to the server config.";
        };
      };

      client = {
        enable = lib.mkEnableOption "LCD panel client (LCDproc)";

        restartForever = lib.mkOption {
          type = bool;
          default = true;
          description = "Try restarting the client forever.";
        };

        settings = lib.mkOption {
          inherit (cfgFmt) type;
          default = { };
          description = "Additional configuration added to the client config.";
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.server.enable || cfg.client.enable) {
      networking.firewall.allowedTCPPorts = lib.mkIf (cfg.server.enable && cfg.server.openPorts) [
        cfg.serverPort
      ];

      systemd.targets.lcd = {
        description = "LCD client/server";
        after = [
          "lcdd.service"
          "lcdproc.service"
        ];
        wantedBy = [ "multi-user.target" ];
      };
    })

    (lib.mkIf cfg.server.enable {
      services.udev.extraRules = lib.concatStringsSep ", " (
        [
          ''ACTION=="add"''
          ''SUBSYSTEMS=="usb"''
          ''ATTRS{idVendor}=="${cfg.server.usb.vid}"''
          ''ATTRS{idProduct}=="${cfg.server.usb.pid}"''
          ''SYMLINK="lcd"''
          ''TAG+="systemd"''
        ]
        ++ lib.optionals cfg.server.usb.permissions [
          ''MODE="0664"''
          ''GROUP="${cfg.server.usb.group}"''
        ]
      );

      systemd.services.lcdd = serviceCfg {
        description = "LCDproc - server";
        serviceConfig = {
          ExecStart = "${lib.getExe' pkgs.lcdproc "LCDd"} -f -c ${serverCfg}";
          SupplementaryGroups = lib.mkIf cfg.server.usb.permissions [ cfg.server.usb.group ];
        };
      };

    })

    (lib.mkIf cfg.client.enable {
      systemd.services.lcdproc = serviceCfg {
        description = "LCDproc - client";
        after = [ "lcdd.service" ];
        # Allow restarting for eternity
        startLimitIntervalSec = lib.mkIf cfg.client.restartForever 0;
        serviceConfig = {
          ExecStart = "${lib.getExe' pkgs.lcdproc "lcdproc"} -f -c ${clientCfg}";
          # If the server is being restarted at the same time, the client will
          # fail as it cannot connect, so space it out a bit.
          RestartSec = "5";
        };
      };
    })
  ];
}
