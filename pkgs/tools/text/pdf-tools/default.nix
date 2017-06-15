{ stdenv, fetchFromGitHub, autoconf, automake, pkgconfig
, emacs, imagemagick, libpng, poppler }:

stdenv.mkDerivation rec {
  name = "pdf-tools-${version}";
  version = "20170417";

  src = fetchFromGitHub {
    owner  = "politza";
    repo   = "pdf-tools";
    rev    = "f314597b2e391f6564e4f9e5cc3af0b4b53f19e9";
    sha256 = "15m7x61m63zxz2jdz52brm9qjzmx1gy24rq8ilmc4drmb0vfmrr2";
  };

  buildInputs = [ emacs imagemagick libpng poppler ];
  nativeBuildInputs = [ autoconf automake pkgconfig ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/pdf-tools
    install -Dm755 server/epdfinfo $out/bin/epdfinfo
    cp -r lisp $out/share/pdf-tools/

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Emacs support library for PDF files.";
    homepage    = https://github.com/politza/pdf-tools;
    license     = licenses.gpl2;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
