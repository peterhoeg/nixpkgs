{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.cpu.intel;

  script = with pkgs; writeScript "peg-cpu.sh" ''
    #!${stdenv.shell} -e

    # https://wiki.archlinux.org/index.php/Dell_Latitude_E6x00

    val=$(${msr-tools}/bin/rdmsr -f 44:32 0xCE)

    for (( ; ; )) ; do
      ${msr-tools}/bin/wrmsr --all 0x199 0x$val
      ${msr-tools}/bin/wrmsr --all 0x19A 0x0
      ${coreutils}/bin/sleep ${cfg.sleepInterval}
    done
  '';

in {

  ###### interface

  options = {

    hardware.cpu.intel = {
      pegCpu = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Peg the CPU to run at max speed to work around broken throttling.

          WARNING: This may harm you computer!
        '';
      };

      sleepInterval = mkOption {
        default = "0.1";
        type = types.string;
        description = ''How long to sleep after reading/writing the registers.'';
      };
    };
  };


  ###### implementation

  config = mkIf config.hardware.cpu.intel.pegCpu {

    boot.kernelModules = [ "cpuid" ];

    systemd.services.peg-cpu = {
      description = "Peg CPU at full speed";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = script;
        Restart = "on-failure";
      };
    };
  };
}
