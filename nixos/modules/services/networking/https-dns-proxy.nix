{ config, lib, pkgs, ... }:

let
  cfg = config.services.https-dns-proxy;

  providerCfg =
    if cfg.provider == "cloudflare"
    then "-b 1.1.1.1,1.0.0.1 -r https://cloudflare-dns.com/dns-query"
    else "-b 8.8.8.8,8.8.4.4 -r https://dns.google/dns-query";

in
{

  ###### interface

  options = with lib; {

    services.https-dns-proxy = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Whether to enable the https-dns-proxy daemon.";
      };

      address = mkOption {
        default = "127.0.0.1";
        type = types.str;
        description = "The address on which to listen";
      };

      port = mkOption {
        default = 5053;
        type = types.port;
        description = "The port on which to listen";
      };

      provider = mkOption {
        default = "cloudflare";
        type = types.enum [ "cloudflare" "google" ];
        description = "The upstream provider to use";
      };

      preferIPv4 = mkOption {
        default = true;
        type = types.bool;
        description = ''
          https_dns_proxy will by default use IPv6 and fail if it is not available. To play it safe, we choose IPv4.
        '';
      };

      extraArgs = mkOption {
        default = [ "-v" ];
        type = types.listOf types.str;
        description = "Additional arguments to pass to the process.";
      };
    };
  };


  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.https-dns-proxy = {
      description = "DNS to DNS over HTTPS (DoH) proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = rec {
        Type = "exec";
        DynamicUser = true;
        ExecStart = lib.concatStringsSep " " (
          [
            "${pkgs.https-dns-proxy}/bin/https_dns_proxy"
            "-a ${toString cfg.address}"
            "-p ${toString cfg.port}"
            "-l -"
            providerCfg
          ]
          ++ lib.optional cfg.preferIPv4 "-4"
          ++ cfg.extraArgs
        );
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ peterhoeg ];
}
