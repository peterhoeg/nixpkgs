{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.huginn;

  sharedEnv = {
    wantedBy = [ "huginn.target" ];
    after = [ "mysql.service" ];
    wants = [ "mysql.service" ];
    environment.RAILS_ENV = "production";
    path = with pkgs; [ "/run/current-system/sw" "/run/wrappers" ];
    serviceConfig.Restart = "on-failure";
  };

in {
  options = {
    services.huginn = {
      enable = mkOption {
        default = false;
        description = ''
          Enable Huginn.
        '';
      };

      workers = mkOption {
        default = 1;
        type = types.int;
        description = ''
          The number of workers to run.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      huginn-ui = sharedEnv // {
        description = "Huginn Web UI";
        serviceConfig = {
          ExecStart = "${pkgs.huginn}/bin/bundle exec unicorn -c config/unicorn.rb";
        };
      };

      "huginn-worker" = sharedEnv // {
        description = "Huginn Worker 1";
        serviceConfig = {
          ExecStartPre = "/bin/sh -c 'echo woot!'";
          ExecStart = "${pkgs.huginn}/bin/rails runner bin/threaded.rb";
        };
      };
    };

    systemd.targets = {
      huginn = {
        description = "Huginn Agents";
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
