{ fetchurl, stdenv, gcj, unzip }:

stdenv.mkDerivation {
  name = "pdftk-2.02";

  src = fetchurl {
    url = "https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-2.02-src.zip";
    sha256 = "1hdq6zm2dx2f9h7bjrp6a1hfa1ywgkwydp14i2sszjiszljnm3qi";
  };

  nativeBuildInputs = [ gcj unzip ];

  enableParallelBuilding = true;

  sourceRoot = "./pdftk";

  hardeningDisable = [ "fortify" "format" ];

  postPatch = ''
    substituteInPlace Makefile.*
      --replace /usr/bin ""
  '';

  NIX_ENFORCE_PURITY = "";

  makeFlags = [
    "LIBGCJ='${gcj.cc}/share/java/libgcj-${gcj.cc.version}.jar'"
    "GCJ=gcj"
    "GCJH=gcjh"
    "GJAR=gjar"
    "-iC" "../java" "all"
    # Makefile.Debian has almost fitting defaults
    "-f" "Makefile.Debian"
    "VERSUFF="
  ];

  installPhase = ''
    install -Dm755 -t $out/bin pdftk
    install -Dm644 -t $out/share/man/man1 ../pdftk.1
  '';


  meta = with stdenv.lib; {
    description = "Simple tool for doing everyday things with PDF documents";
    homepage = https://www.pdflabs.com/tools/pdftk-server/;
    license = licenses.gpl2;
    maintainers = with maintainers; [viric raskin];
    platforms = with platforms; linux;
  };
}
