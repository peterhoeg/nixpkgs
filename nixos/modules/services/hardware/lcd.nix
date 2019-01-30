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

  serviceCfg = {
    DynamicUser = true;
    Restart = "on-failure";
    Slice = "lcd.slice";
  };

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
        description = "Host on which LCDd is listening.";
        type = str;
        default = "localhost";
      };

      serverPort = mkOption {
        description = "Port on which LCDd is listening.";
        type = int;
        default = 13666;
      };

      server = {
        enable = mkEnableOption "LCD panel server (LCDd)";

        openPorts = mkOption {
          description = "Open the ports in the firewall";
          type = bool;
          default = false;
        };

        usb = {
          permissions = mkOption {
            description = ''
              Set group-write permissions on a USB device.
              </para>
              <para>
              A USB connected LCD panel will most likely require having its
              permissions modified for lcdd to write to it. Enabling this option
              sets group-write permissions on the device identified by
              <option>services.hardware.lcd.usbVid</option> and
              <option>services.hardware.lcd.usbPid</option>. In order to find the
              values, you can run the <command>lsusb</command> command. Example
              output:
              </para>
              <para>
              <literal>
              Bus 005 Device 002: ID 0403:c630 Future Technology Devices International, Ltd lcd2usb interface
              </literal>
              </para>
              <para>
              In this case the vendor id is 0403 and the product id is c630.
            '';
            type = bool;
            default = false;
          };

          vid = mkOption {
            description = "The vendor ID of the USB device to claim.";
            type = str;
          };

          pid = mkOption {
            description = "The product ID of the USB device to claim.";
            type = str;
          };

          group = mkOption {
            description = "The group to grant write permissions on the USB device";
            type = str;
            default = "dialout";
          };
        };

        settings = mkOption {
          description = "Additional configuration added to the server config.";
          type = cfgFmt.type;
          default = { };
        };
      };

      client = {
        enable = mkEnableOption "LCD panel client (LCDproc)";

        restartForever = mkOption {
          description = "Try restarting the client forever.";
          type = bool;
          default = true;
        };

        settings = mkOption {
          description = "Additional configuration added to the client config.";
          type = cfgFmt.type;
          default = { };
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
      lcdd = mkIf cfg.server.enable {
        description = "LCDproc - server";
        wantedBy = [ "lcd.target" ];
        serviceConfig = serviceCfg // {
          ExecStart = "${pkg}/bin/LCDd -f -c ${serverCfg}";
          SupplementaryGroups = mkIf cfg.server.usb.permissions [ cfg.server.usb.group ];
        };
      };

      lcdproc = mkIf cfg.client.enable {
        description = "LCDproc - client";
        after = [ "lcdd.service" ];
        wantedBy = [ "lcd.target" ];
        # Allow restarting for eternity
        startLimitIntervalSec = lib.mkIf cfg.client.restartForever 0;
        serviceConfig = serviceCfg // {
          ExecStart = "${pkg}/bin/lcdproc -f -c ${clientCfg}";
          # If the server is being restarted at the same time, the client will
          # fail as it cannot connect, so space it out a bit.
          RestartSec = "5";
        };
      };
    };

    systemd.targets.lcd = {
      description = "LCD client/server";
      after = [ "lcdd.service" "lcdproc.service" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
