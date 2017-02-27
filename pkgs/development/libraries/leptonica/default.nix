{ stdenv, fetchFromGitHub, cmake, pkgconfig
, libpng, libtiff, libjpeg, libwebp, zlib }:

stdenv.mkDerivation rec {
  name = "leptonica-${version}";
  version = "1.74.1";

  src = fetchFromGitHub {
    owner  = "DanBloomberg";
    repo   = "leptonica";
    rev    = version;
    sha256 = "1a3kd34cgwssxlyjc4n4wb4xkjxjxknmvnzlcvcipwzsdrmclda8";
  };

  buildInputs = [ libpng libtiff libjpeg libwebp zlib ];
  nativeBuildInputs = [ cmake pkgconfig ];

  meta = with stdenv.lib; {
    description = "Image processing and analysis library";
    homepage = http://www.leptonica.org/;
    # Its own license: http://www.leptonica.org/about-the-license.html
    license = licenses.free;
    platforms = platforms.unix;
  };
}
