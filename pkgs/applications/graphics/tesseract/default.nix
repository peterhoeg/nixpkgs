{ stdenv, fetchFromGitHub, cmake, pkgconfig
, leptonica, libpng, libtiff, icu, pango, opencl-headers
}:

stdenv.mkDerivation rec {
  name = "tesseract-${version}";
  version = "3.05.00";

  src = fetchFromGitHub {
    owner  = "tesseract-ocr";
    repo   = "tesseract";
    rev    = version;
    sha256 = "11wrpcfl118wxsv2c3w2scznwb48c4547qml42s2bpdz079g8y30";
  };

  tessdata = fetchFromGitHub {
    owner  = "tesseract-ocr";
    repo   = "tessdata";
    rev    = "3cf1e2df1fe1d1da29295c9ef0983796c7958b7d";
    sha256 = "1v4b63v5nzcxr2y3635r19l7lj5smjmc9vfk0wmxlryxncb4vpg7";
  };

  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ leptonica libpng libtiff icu pango opencl-headers ];

  LIBLEPT_HEADERSDIR = "${leptonica}/include";

  postInstall = "cp -Rt \"$out/share/tessdata\" \"$tessdata/\"*";

  meta = with stdenv.lib; {
    description = "OCR engine";
    homepage = http://code.google.com/p/tesseract-ocr/;
    license = licenses.asl20;
    maintainers = with maintainers; [viric];
    platforms = with platforms; linux;
  };
}
