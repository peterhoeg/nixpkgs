# tcsd daemon.

{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.hardware.tpm;

  stateDir = "/var/lib/tpm";

  pkg = if cfg.version == "1.2" then pkgs.tpm-tools else pkgs.tpm2-tools;

  tcsdConf = pkgs.writeText "tcsd.conf" ''
    port = 30003
    num_threads = 10
    system_ps_file = ${stateDir}/system.data
    # This is the log of each individual measurement done by the system.
    # By re-calculating the PCR registers based on this information, even
    # finer details about the measured environment can be inferred than
    # what is available directly from the PCR registers.
    firmware_log_file = /sys/kernel/security/tpm0/binary_bios_measurements
    kernel_log_file = /sys/kernel/security/ima/binary_runtime_measurements
    firmware_pcrs = ${cfg.firmwarePCRs}
    kernel_pcrs = ${cfg.kernelPCRs}
    platform_cred = ${cfg.platformCred}
    conformance_cred = ${cfg.conformanceCred}
    endorsement_cred = ${cfg.endorsementCred}
    #remote_ops = create_key,random
    #host_platform_class = server_12
    #all_platform_classes = pc_11,pc_12,mobile_12
  '';

in
{

  ###### interface

  options = {

    services.hardware.tpm = with types; {

      enable = mkOption {
        default = false;
        type = bool;
        description = ''
          Whether to enable tcsd, a Trusted Computing management service
          that provides TCG Software Stack (TSS).  The tcsd daemon is
          the only portal to the Trusted Platform Module (TPM), a hardware
          chip on the motherboard.
        '';
      };

      version = mkOption {
        default = "1.2";
        type = enum [ "1.2" "2.0" ];
        description = ''
          Version of hardware to support.

          We cannot auto-detect this, so you need to specify 1.2 or 2.0 based on available hardware.
        '';
      };

      firmwarePCRs = mkOption {
        default = "0,1,2,3,4,5,6,7";
        type = types.string;
        description = "PCR indices used in the TPM for firmware measurements.";
      };

      kernelPCRs = mkOption {
        default = "8,9,10,11,12";
        type = types.string;
        description = "PCR indices used in the TPM for kernel measurements.";
      };

      platformCred = mkOption {
        default = "${stateDir}/platform.cert";
        type = types.path;
        description = ''
          Path to the platform credential for your TPM. Your TPM
          manufacturer may have provided you with a set of credentials
          (certificates) that should be used when creating identities
          using your TPM. When a user of your TPM makes an identity,
          this credential will be encrypted as part of that process.
          See the 1.1b TPM Main specification section 9.3 for information
          on this process. '';
      };

      conformanceCred = mkOption {
        default = "${stateDir}/conformance.cert";
        type = types.path;
        description = ''
          Path to the conformance credential for your TPM.
          See also the platformCred option'';
      };

      endorsementCred = mkOption {
        default = "${stateDir}/endorsement.cert";
        type = types.path;
        description = ''
          Path to the endorsement credential for your TPM.
          See also the platformCred option'';
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    # tpm 2 devices need to be world readable - writable?
    services.udev.extraRules = lib.mkIf (cfg.version == "2.0") ''
      SUBSYSTEM=="tpm", ACTION=="add", MODE="0644"
    '';

    systemd.services = {
      tcsd = lib.mkIf (cfg.version == "1.2") {
        description = "TCSD";
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ trousers ];
        serviceConfig = {
          DynamicUser = true;
          StateDirectory = "tss";
          User = "tss";
          Group = "tss";
          ExecStart = "${pkgs.trousers}/sbin/tcsd -f -c ${tcsdConf}";
          Restart = "on-failure";
        };
      };
    };
  };
}
