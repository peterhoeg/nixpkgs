{ lib, cfg }:

{
  options = with lib; with types; {
    enable = mkOption {
      type = bool;
      default = (cfg.role == "server");
      description = "Enable the dashboard";
    };

    host = mkOption {
      type = str;
      default = "127.0.0.1";
      description = "The IP address on which Uchiwa will listen.";
    };

    port = mkOption {
      type = int;
      default = 3000;
      description = "The port on which Uchiwa will listen.";
    };

    refresh = mkOption {
      type = int;
      default = 5;
      description = "UI refresh interval.";
    };

    proxy = mkOption {
      type = bool;
      default = false;
      description = "Proxy traffic to/from the sensu dashboard.";
    };

    path = mkOption {
      type = str;
      default = "/";
      description = "The path to the dashboard if behind a proxy.";
    };

    UsersOptions = mkOption {
      description = "Options relevant to all users";
      default = {};
      type = submodule {
        options = {
          DefaultTheme = mkOption {
            type = enum [ "uchiwa-default" "uchiwa-dark" ];
            default = "uchiwa-dark";
            description = "The theme to use.";
          };
        };
      };
    };
  };
}
