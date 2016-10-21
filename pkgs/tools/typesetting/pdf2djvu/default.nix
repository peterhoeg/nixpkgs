{ stdenv, fetchurl, autoreconfHook, pkgconfig
, djvulibre, exiv2, fontconfig, graphicsmagick, libjpeg, libuuid, poppler }:

stdenv.mkDerivation rec {
  version = "0.9.4";
  name = "pdf2djvu-${version}";

  src = fetchurl {
    url = "https://bitbucket.org/jwilk/pdf2djvu/downloads/${name}.tar.xz";
    sha256 = "1a1gwr6yzbiximbpgg4rc69dq8g3jmxwcbcwqk0fhfbgzj1j4w65";
  };

  patches = [
    ./ignore_tools.patch
  ];

  buildInputs = [ autoreconfHook pkgconfig djvulibre.dev graphicsmagick poppler fontconfig libjpeg libuuid exiv2 ];

  propagatedBuildInputs = [ djvulibre.bin ];

  meta = with stdenv.lib; {
    description = "Creates djvu files from PDF files";
    homepage = http://code.google.com/p/pdf2djvu/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ pSub ];
    inherit version;
  };
}
