{ lib, buildGoModule, fetchFromGitHub, nixosTests }:

buildGoModule rec {
  pname = "smokeping_prober";
  version = "0.6.1";

  ldflags =
    let
      setVars = {
        Version = version;
        BuildUser = "nix";
        Branch = version;
        Revision = version;
      };
      varFlags = lib.concatStringsSep " " (lib.mapAttrsToList (name: value: "-X github.com/prometheus/common/version.${name}=${value}") setVars);
    in
    [ "${varFlags}" "-s" "-w" ];

  src = fetchFromGitHub {
    owner = "SuperQ";
    repo = "smokeping_prober";
    rev = "v" + version;
    hash = "sha256-tph9TZwMWKlJC/YweO9BU3+QRIugqc3ob5rqXThyR1c=";
  };

  vendorSha256 = "sha256-emabuOm5tuPNZWmPHJWUWzFVjuLrY7biv8V/3ru73aU=";

  doCheck = true;

  passthru.tests = { inherit (nixosTests.prometheus-exporters) smokeping; };

  meta = with lib; {
    description = "Prometheus exporter for sending continual ICMP/UDP pings";
    homepage = "https://github.com/SuperQ/smokeping_prober";
    license = licenses.asl20;
    maintainers = with maintainers; [ lukegb ];
    platforms = platforms.unix;
  };
}
