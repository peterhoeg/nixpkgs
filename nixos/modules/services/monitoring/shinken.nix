{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.shinken;

  shinkenPack = name: src: {
    pkgs.stdenv.mkDerivation {
      name = "shinken-plugin-${name}";
      inherit src;
      buildInputs = with pkgs; [ unzip ];
      installPhase = "mkdir -p $out; cp -R * $out/";
    };
  };

  stateDir = "/var/lib/shinken";
  logDir = "/var/log/shinken";

  shinkenObjectDefs = cfg.objectDefs;

  shinkenObjectDefsDir = pkgs.runCommand "shinken-objects" {inherit shinkenObjectDefs;}
  "mkdir -p $out; ln -s $shinkenObjectDefs $out/";

  cfgFile = pkgs.writeText "shinken.cfg" ''
      # Paths for state and logs.
      log_file=${shinkenLogDir}/current
      log_archive_path=${shinkenLogDir}/archive
      status_file=${shinkenState}/status.dat
      object_cache_file=${shinkenState}/objects.cache
      temp_file=${shinkenState}/shinken.tmp
      lock_file=/var/run/shinken.lock # Not used I think.
      state_retention_file=${shinkenState}/retention.dat
      query_socket=${shinkenState}/shinken.qh
      check_result_path=${shinkenState}
      command_file=${shinkenState}/shinken.cmd

      # Configuration files.
      #resource_file=resource.cfg
      cfg_dir=${shinkenObjectDefsDir}

      # Uid/gid that the daemon runs under.
      shinken_user=shinken
      shinken_group=nogroup

      # Misc. options.
      illegal_macro_output_chars=`~$&|'"<>
      retain_state_information=1
    ''; # "

  # Plain configuration for the Shinken web-interface with no
  # authentication.
  shinkenCGICfgFile = pkgs.writeText "shinken.cgi.conf"
''
      main_config_file=${cfg.mainConfigFile}
      use_authentication=0
      url_html_path=${cfg.urlPath}
    '';

  extraHttpdConfig =
''
      ScriptAlias ${cfg.urlPath}/cgi-bin ${pkgs.shinken}/sbin

      <Directory "${pkgs.shinken}/sbin">
        Options ExecCGI
        AllowOverride None
        Order allow,deny
        Allow from all
        SetEnv SHINKEN_CGI_CONFIG ${cfg.cgiConfigFile}
      </Directory>

      Alias ${cfg.urlPath} ${pkgs.shinken}/share

      <Directory "${pkgs.shinken}/share">
        Options None
        AllowOverride None
        Order allow,deny
        Allow from all
      </Directory>
    '';

in {
  options = {
    services.shinken = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to use <link xlink:href='http://www.shinken-monitoring.org/'>Shinken</link>
          to monitor your system or network.
        '';
      };

      objectDefs = mkOption {
        description = "
        A list of Shinken object configuration files that must define
        the hosts, host groups, services and contacts for the
        network that you want Shinken to monitor.
        ";
      };

      packs = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Packs to be added to the Shinken configuration.";
      };

      plugins = mkOption {
        type = types.listOf types.package;
        default = [pkgs.shinkenPluginsOfficial pkgs.ssmtp];
        defaultText = "[pkgs.shinkenPluginsOfficial pkgs.ssmtp]";
        description = "
        Packages to be added to the Shinken <envar>PATH</envar>.
        Typically used to add plugins, but can be anything.
        ";
      };

      mainConfigFile = mkOption {
        type = types.package;
        default = shinkenCfgFile;
        defaultText = "shinkenCfgFile";
        description = "
        Derivation for the main configuration file of Shinken.
        ";
      };

      cgiConfigFile = mkOption {
        type = types.package;
        default = shinkenCGICfgFile;
        defaultText = "shinkenCGICfgFile";
        description = "
        Derivation for the configuration file of Shinken CGI scripts
        that can be used in web servers for running the Shinken web interface.
        ";
      };

      enableWebInterface = mkOption {
        default = false;
        description = "
        Whether to enable the Shinken web interface.  You should also
        enable Apache (<option>services.httpd.enable</option>).
        ";
      };

      urlPath = mkOption {
        default = "/shinken";
        description = "
        The URL path under which the Shinken web interface appears.
        That is, you can access the Shinken web interface through
        <literal>http://<replaceable>server</replaceable>/<replaceable>urlPath</replaceable></literal>.
        ";
      };
    };
  };


  config = mkIf cfg.enable {
    users.extraUsers.shinken = {
      description = "Shinken user ";
      uid         = config.ids.uids.shinken;
      home        = shinkenState;
      createHome  = true;
    };

    # This isn't needed, it's just so that the user can type "shinkentats
    # -c /etc/shinken.cfg".
    environment.etc = [
      { source = cfg.mainConfigFile;
        target = "shinken.cfg";
      }
    ];

    environment.systemPackages = [ pkgs.shinken ];
    systemd.services.shinken = {
      description = "Shinken monitoring daemon";
      path     = [ pkgs.shinken ];
      wantedBy = [ "multi-user.target" ];
      after    = [ "network-interfaces.target" ];

      serviceConfig = {
        User = "shinken";
        Restart = "always";
        RestartSec = 2;
        PermissionsStartOnly = true;
      };

      preStart = ''
        mkdir -m 0755 -p ${shinkenState} ${shinkenLogDir}
        chown shinken ${shinkenState} ${shinkenLogDir}
      '';

      script = ''
        for i in ${toString cfg.plugins}; do
        export PATH=$i/bin:$i/sbin:$i/libexec:$PATH
        done
        exec ${pkgs.shinken}/bin/shinken ${cfg.mainConfigFile}
      '';
    };

    services.httpd.extraConfig = optionalString cfg.enableWebInterface extraHttpdConfig;
  };
}
