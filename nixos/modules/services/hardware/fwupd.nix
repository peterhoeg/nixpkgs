# fwupd daemon.

{ config, lib, pkgs, ... }:

let
  cfg = config.services.fwupd;

  inherit (lib)
    concatStringsSep
    literalExpression mkRenamedOptionModule mkOption mkIf types
    listToAttrs nameValuePair;

  fileList = mkOption {
    description = "";
    default = [ ];
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          description = "File name";
          type = types.str;
        };

        value = mkOption {
          description = "Attribute set of values";
          type = types.attrs;
        };
      };
    });
  };

  mergeFileWithAttrs = fileName: attrs:
    pkgs.runCommandLocal fileName { } (
      let
        overrides = (pkgs.formats.ini { }).generate "${fileName}-override" attrs;
      in
      ''
        _copy_or_create()  {
          local file="${cfg.package.installedTests}/etc/fwupd/$1"

          if [ -e "$file" ]; then
            cp --no-preserve=all "$file" $out
          else
            touch $out
          fi
        }

        _copy_or_create ${fileName}

        ${lib.getExe pkgs.crudini} --merge $out < ${overrides}
      ''
    );

  customEtc = {
    "fwupd/daemon.conf".source =
      mergeFileWithAttrs "daemon.conf" {
        fwupd = {
          DisabledDevices = concatStringsSep ";" cfg.disabledDevices;
          DisabledPlugins = concatStringsSep ";" cfg.disabledPlugins;
        };
      };

    "fwupd/uefi.conf".source = mergeFileWithAttrs "uefi.conf" {
      uefi.OverrideESPMountPoint = config.boot.loader.efi.efiSysMountPoint;
    };

    "fwupd/remotes.d/lvfs-testing.conf".source = mergeFileWithAttrs "lvfs-testing.conf" {
      "fwupd Remote" = {
        Enabled = cfg.enableTestRemote;
      };
    };
  };

  originalEtc =
    let
      mkEtcFile = n: nameValuePair n { source = "${cfg.package}/etc/${n}"; };
    in
    listToAttrs (map mkEtcFile cfg.package.filesInstalledToEtc);

  extraTrustedKeys =
    let
      mkName = p: "pki/fwupd/${baseNameOf (toString p)}";
      mkEtcFile = p: nameValuePair (mkName p) { source = p; };
    in
    listToAttrs (map mkEtcFile cfg.extraTrustedKeys);

in
{

  ###### interface
  options.services.fwupd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable fwupd, a DBus service that allows
        applications to update firmware.
      '';
    };

    disabledDevices = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "2082b5e0-7a64-478a-b1b2-e3404fab6dad" ];
      description = ''
        Allow disabling specific devices by their GUID
      '';
    };

    disabledPlugins = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "udev" ];
      description = ''
        Allow disabling specific plugins
      '';
    };

    extraTrustedKeys = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = literalExpression "[ /etc/nixos/fwupd/myfirmware.pem ]";
      description = ''
        Installing a public key allows firmware signed with a matching private
        key to be recognized as trusted, which may require less authentication
        to install than for untrusted files. By default trusted firmware can be
        upgraded (but not downgraded) without the user or administrator
        password. Only very few keys are installed by default.
      '';
    };

    enableTestRemote = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable test remote. This is used by
        <link xlink:href="https://github.com/fwupd/fwupd/blob/master/data/installed-tests/README.md">installed tests</link>.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.fwupd;
      defaultText = literalExpression "pkgs.fwupd";
      description = ''
        Which fwupd package to use.
      '';
    };

    # files = fileList;

    # remotes = fileList;
  };

  imports = [
    (mkRenamedOptionModule [ "services" "fwupd" "blacklistDevices" ] [ "services" "fwupd" "disabledDevices" ])
    (mkRenamedOptionModule [ "services" "fwupd" "blacklistPlugins" ] [ "services" "fwupd" "disabledPlugins" ])
  ];

  ###### implementation
  config = mkIf cfg.enable {
    # Disable test related plug-ins implicitly so that users do not have to care about them.
    services.fwupd.disabledPlugins = cfg.package.defaultDisabledPlugins;

    environment.systemPackages = [ cfg.package ];

    # customEtc overrides some files from the package
    environment.etc = originalEtc // customEtc // extraTrustedKeys;

    services.dbus.packages = [ cfg.package ];

    services.udev.packages = [ cfg.package ];

    systemd.packages = [ cfg.package ];
  };

  meta = {
    maintainers = pkgs.fwupd.meta.maintainers;
  };
}
