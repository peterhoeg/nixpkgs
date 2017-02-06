{ config, lib, pkgs, ... }:

with lib;

let

  inherit (pkgs) mysql gzip;

  cfg = config.services.mysqlBackup ;


  mysqlBackupCron = db : ''
    ${cfg.period} ${cfg.user} ${mysql}/bin/mysqldump ${if cfg.singleTransaction then "--single-transaction" else ""} ${db} | ${gzip}/bin/gzip -c > ${location}/${db}.gz
  '';

in {
  options = {
    services.mysqlBackup = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable MySQL backups.
        '';
      };

      period = mkOption {
        default = ["03:45"];
        type = types.listOf types.str;
        description = ''
          Specification (in the format described by
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>5</manvolnum></citerefentry>) of the time at
          which the optimiser will run.
        '';
      };

      user = mkOption {
        default = "mysql";
        description = ''
          User to be used to perform backup.
        '';
      };

      databases = mkOption {
        default = [];
        description = ''
          List of database names to dump.
        '';
      };

      location = mkOption {
        default = "/var/backup/mysql";
        description = ''
          Location to put the gzipped MySQL database dumps.
        '';
      };

      singleTransaction = mkOption {
        default = false;
        description = ''
          Whether to create database dump in a single transaction
        '';
      };
    };

  };

  config = mkIf config.services.mysqlBackup.enable {

    systemd.services = {
      "mysql-backup-${database} =
      { description = "Nix Store Optimiser";
        serviceConfig.ExecStart = "${config.mysql.package}/bin/nix-store --optimise";
        startAt = optionals cfg.enable cfg.dates;
      };

    services.cron.systemCronJobs = map mysqlBackupCron config.services.mysqlBackup.databases;

    system.activationScripts.mysqlBackup = stringAfter [ "stdio" "users" ]
      ''
        mkdir -m 0700 -p ${config.services.mysqlBackup.location}
        chown ${config.services.mysqlBackup.user} ${config.services.mysqlBackup.location}
      '';

  };

}
