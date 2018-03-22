{ stdenv, fetchurl, autoreconfHook, cmocka, pkgconfig
, python3Packages
, tpm2-tss, curl, openssl }:

let
  pname = "tpm2-tools";

in stdenv.mkDerivation rec {
  name = "tpm2-tools-${version}";
  version = "3.0.3";

  src = fetchurl {
    url = "http://github.com/tpm2-software/${pname}/releases/download/${version}/${name}.tar.gz";
    sha256 = "1794qsrw0p8s2m5nhaixnj9lp6hqk8m8bqb1ml7yzbv5c5jw1469";
  };

  autoreconfPhase = ":";

  nativeBuildInputs = [
    autoreconfHook cmocka pkgconfig
  ] ++ (with python3Packages; [
    python pyyaml
  ]);

  buildInputs = [ curl openssl tpm2-tss ];

  enableParallelBuilding = true;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Management tools for TPM2 hardware";
    longDescription = ''
      tpm2-tools is an open-source package designed to enable user and
      application enablement of Trusted Computing using a Trusted Platform
      Module (TPM), similar to a smart card environment.
    '';
    homepage    = https://sourceforge.net/projects/trousers/files/tpm-tools/;
    license     = licenses.bsd3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
