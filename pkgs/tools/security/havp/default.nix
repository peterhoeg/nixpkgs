{ stdenv, fetchurl, clamav, openssl, perl }:

stdenv.mkDerivation rec {
  name = "havp-${version}";
  version = "0.92a";

  src = fetchurl {
    url = "http://www.havp.org/download/${name}.tar.gz";
    sha256 = "16hf1zshn7wgxjy7fwyddx3rf2nhdp3g0nhmlx51hf2p1cwqdv0d";
  };

  postPatch = ''
    sed -i havp/Makefile.in \
      -e '/localstatedir/d' \
      -e '/init\.d/d'
  '';

  buildInputs = [ clamav openssl ];

  nativeBuildInputs = [ perl ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "HTTP Anti Virus Proxy";
    homepage    = https://www.havp.org;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
