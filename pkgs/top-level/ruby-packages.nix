{ callPackage }:

{
  sensu-plugins-aws = callPackage ../development/ruby-modules/sensu-plugins-aws { };
  sensu-plugins-cgroups = callPackage ../development/ruby-modules/sensu-plugins-cgroups { };
  sensu-plugins-cpu-checks = callPackage ../development/ruby-modules/sensu-plugins-cpu-checks { };
  sensu-plugins-disk-checks = callPackage ../development/ruby-modules/sensu-plugins-disk-checks { };
  sensu-plugins-dns = callPackage ../development/ruby-modules/sensu-plugins-dns { };
  sensu-plugins-environmental-checks = callPackage ../development/ruby-modules/sensu-plugins-environmental-checks { };
  sensu-plugins-filesystem-checks = callPackage ../development/ruby-modules/sensu-plugins-filesystem-checks { };
  sensu-plugins-http = callPackage ../development/ruby-modules/sensu-plugins-http { };
  sensu-plugins-influxdb = callPackage ../development/ruby-modules/sensu-plugins-influxdb { };
  sensu-plugins-io-checks = callPackage ../development/ruby-modules/sensu-plugins-io-checks { };
  sensu-plugins-ipmi = callPackage ../development/ruby-modules/sensu-plugins-ipmi { };
  sensu-plugins-load-checks = callPackage ../development/ruby-modules/sensu-plugins-load-checks { };
  sensu-plugins-logs = callPackage ../development/ruby-modules/sensu-plugins-logs { };
  sensu-plugins-mailer = callPackage ../development/ruby-modules/sensu-plugins-mailer { };
  sensu-plugins-memory-checks = callPackage ../development/ruby-modules/sensu-plugins-memory-checks { };
  sensu-plugins-mysql = callPackage ../development/ruby-modules/sensu-plugins-mysql { };
  sensu-plugins-network-checks = callPackage ../development/ruby-modules/sensu-plugins-network-checks { };
  sensu-plugins-nginx = callPackage ../development/ruby-modules/sensu-plugins-nginx { };
  sensu-plugins-ntp = callPackage ../development/ruby-modules/sensu-plugins-ntp { };
  sensu-plugins-pushover = callPackage ../development/ruby-modules/sensu-plugins-pushover { };
  sensu-plugins-rabbitmq = callPackage ../development/ruby-modules/sensu-plugins-rabbitmq { };
  sensu-plugins-raid-checks = callPackage ../development/ruby-modules/sensu-plugins-raid-checks { };
  sensu-plugins-redis = callPackage ../development/ruby-modules/sensu-plugins-redis { };
  sensu-plugins-sensu = callPackage ../development/ruby-modules/sensu-plugins-sensu { };
  sensu-plugins-sftp = callPackage ../development/ruby-modules/sensu-plugins-sftp { };
  sensu-plugins-snmp = callPackage ../development/ruby-modules/sensu-plugins-snmp { };
  sensu-plugins-systemd = callPackage ../development/ruby-modules/sensu-plugins-systemd { };
  sensu-plugins-ubiquiti = callPackage ../development/ruby-modules/sensu-plugins-ubiquiti { };
  sensu-plugins-uptime-checks = callPackage ../development/ruby-modules/sensu-plugins-uptime-checks { };
}
