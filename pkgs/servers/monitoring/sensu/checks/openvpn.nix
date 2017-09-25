{ stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "sensu-check-openvpn-${version}";
  version = "20170630";

  src = fetchFromGitHub {
    owner  = "liquidat";
    repo   = "nagios-icinga-openvpn";
    rev    = "ba625c3716d7ece5372989c9811561aae0b49c6b";
    sha256 = "0b2g7ybm42vybcshaa3drkwp3i6xrlyilqgf77lh3v7kqajcfyxw";
  };

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 check_openvpn $out/bin/check_openvpn

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "A sensu plugin for OpenVPN";
    maintainers = with maintainers; [ peterhoeg ];
  };
}
