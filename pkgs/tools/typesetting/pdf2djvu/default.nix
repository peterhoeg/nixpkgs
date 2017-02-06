{ stdenv, fetchurl, autoreconfHook, pkgconfig, makeWrapper
, djvulibre, exiv2, fontconfig, graphicsmagick, libjpeg, poppler, libuuid
, python2Packages }:

let
  fonts = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig></fontconfig>
  '';

in stdenv.mkDerivation rec {
  name = "pdf2djvu-${version}";
  version = "0.9.5";

  src = fetchurl {
    url    = "http://github.com/jwilk/pdf2djvu/releases/download/${version}/${name}.tar.xz";
    sha256 = "0fr8b44rsqll2m6qnh9id1lfc980k7rj3aq975mwba4y57rwnlnc";
  };

  doCheck = true;

  nativeBuildInputs = [ autoreconfHook makeWrapper pkgconfig ];

  buildInputs = [ djvulibre graphicsmagick poppler exiv2 fontconfig libjpeg libuuid ]
  ++ (with python2Packages; [ python nose ]);

  preConfigure = ''
    export FONTCONFIG_PATH=$out/etc/fonts

    substituteInPlace configure configure.ac \
      --replace '$djvulibre_bin_path' ${djvulibre.bin}/bin
  '';

  postInstall = ''
    install -Dm644 ${fonts} $FONTCONFIG_PATH/fonts.conf
  '';

  fixupPhase = ''
    wrapProgram $out/bin/pdf2djvu \
      --suffix FONTCONFIG_PATH : $out/etc/fonts
  '';

  checkPhase = ''
    make test
  '';

  meta = with stdenv.lib; {
    description = "Creates djvu files from PDF files";
    homepage = http://code.google.com/p/pdf2djvu/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ pSub ];
    inherit version;
  };
}
