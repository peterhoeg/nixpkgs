{ stdenv, lib, fetchurl, makeWrapper
, fpc, gtk2, glib, pango, atk, gdk_pixbuf
, libXi, xorgproto, libX11, libXext
, withQt ? false, qt5 ? null, qtpas ? null
}:

stdenv.mkDerivation rec {
  name = "lazarus-${version}";
  version = "1.8.4";
  # version = "2.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/lazarus/Lazarus%20Zip%20_%20GZip/Lazarus%20${version}/lazarus-${version}.tar.gz";
    sha256 = "1s8hdip973fc1lynklddl0mvg2jd2lzkfk8hzb8jlchs6jn0362s";
    # sha256 = "0vkxqryqp1lmsk0anylk6cl86rw1q6x5d9c2pzsdkvvd8z8g7mx6";
  };

  buildInputs = [
    fpc gtk2 glib libXi xorgproto
    libX11 libXext pango atk
    stdenv.cc gdk_pixbuf
  ] ++ lib.optionals withQt (with qt5; [ qtbase qtpas ]);

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "FPC=fpc"
    "PP=fpc"
    "REQUIRE_PACKAGES+=tachartlazaruspkg"
    "bigide"
    "LAZARUS_INSTALL_DIR==$(out)/share/lazarus/"
    "INSTALL_PREFIX=$(out)/"
  ];

  LCL_PLATFORM = if withQt then "qt5" else "gtk2";

  NIX_LDFLAGS = [
    "-L${stdenv.cc.cc.lib}/lib"
    "-lXi"
    "-lX11"
    "-lglib-2.0"
    "-lgtk-x11-2.0"
    "-lgdk-x11-2.0"
    "-lc"
    "-lXext"
    "-lpango-1.0"
    "-latk-1.0"
    "-lgdk_pixbuf-2.0"
    "-lcairo"
    "-lgcc_s"
  ];

  preBuild = ''
    mkdir -p $out/{lazarus,share}
    tar xf ${fpc.src} --strip-components=1 -C $out/share -m
    sed -e 's@/usr/fpcsrc@'"$out/share/fpcsrc@" -i ide/include/unix/lazbaseconf.inc
  '';

  postInstall = ''
    wrapProgram $out/bin/startlazarus \
      --prefix NIX_LDFLAGS  ' ' "'$NIX_LDFLAGS'" \
      --prefix LCL_PLATFORM ' ' "'$LCL_PLATFORM'"
  '';

  meta = with stdenv.lib; {
    description = "Lazarus graphical IDE for the FreePascal language";
    homepage = https://www.lazarus.freepascal.org;
    license = licenses.gpl2Plus ;
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
  };
}
