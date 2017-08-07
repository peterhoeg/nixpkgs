{ stdenv, fetchurl, python2Packages }:

python2Packages.buildPythonApplication rec {
  name = "check-esx-wbem-${version}";
  version = "20161013";

  src = fetchurl {
    url = "https://www.claudiokuenzler.com/nagios-plugins/check_esxi_hardware.py";
    sha256 = "0zrlwff16b33kawnwgzv0i6hax3xsb99nfyjfjs72aa60rrrp41v";
  };

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 $src $out/bin/check_esxi_hardware.py

    runHook postInstall
  '';

  propagatedBuildInputs = with python2Packages; [ pywbem ];

  meta = with stdenv.lib; {

  };
}
