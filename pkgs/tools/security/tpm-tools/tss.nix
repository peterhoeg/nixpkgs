{ stdenv, fetchFromGitHub, fetchurl, autoreconfHook, pkgconfig
, libgcrypt, uriparser }:

let
  pname = "tpm2-tss";

in stdenv.mkDerivation rec {
  name = "tpm2-tss-${version}";
  version = "1.4.0";

  srcGH = fetchFromGitHub {
    owner  = "tpm2-software";
    repo   = "tpm2-tss";
    rev    = "${version}";
    sha256 = "19m5q890484i2ya9jngj1694l2wsck5x3h0i9bvamz35pjlfrwds";
  };

  src = fetchurl {
    url = "http://github.com/tpm2-software/${pname}/releases/download/${version}/${name}.tar.gz";
    sha256 = "0cchn2vpzxs2kyn7f222v2pax9lkw0rp1xs7p9pnxqbbag6891yg";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ libgcrypt uriparser ];

  autoreconfPhase = ":";

  enableParallelBuilding = true;

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
