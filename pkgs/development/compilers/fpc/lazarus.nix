{ stdenv, fetchurl
, fpc
, gtk2, glib, pango, atk, gdk_pixbuf
, libXi, inputproto, libX11, xproto, libXext, xextproto
, makeWrapper
}:

let
  version = "1.8.0";
  versionSuffix = "";

in stdenv.mkDerivation rec {
  name = "lazarus-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lazarus/Lazarus%20Zip%20_%20GZip/Lazarus%20${version}/lazarus-${version}${versionSuffix}.tar.gz";
    sha256 = "0i58ngrr1vjyazirfmz0cgikglc02z1m0gcrsfw9awpi3ax8h21j";
  };

  buildInputs = [
    fpc gtk2 glib libXi inputproto
    libX11 xproto libXext xextproto pango atk
    stdenv.cc makeWrapper gdk_pixbuf
  ];

  makeFlags = [
    "FPC=fpc"
    "PP=fpc"
    "REQUIRE_PACKAGES+=tachartlazaruspkg"
    "bigide"
  ];

  preBuild = ''
    export makeFlags="$makeFlags LAZARUS_INSTALL_DIR=$out/share/lazarus/ INSTALL_PREFIX=$out/"
    export NIX_LDFLAGS="$NIX_LDFLAGS -L${stdenv.cc.cc.lib}/lib -lXi -lX11 -lglib-2.0 -lgtk-x11-2.0 -lgdk-x11-2.0 -lc -lXext -lpango-1.0 -latk-1.0 -lgdk_pixbuf-2.0 -lcairo -lgcc_s"
    export LCL_PLATFORM=gtk2
    mkdir -p $out/share "$out/lazarus"
    tar xf ${fpc.src} --strip-components=1 -C $out/share -m
    sed -e 's@/usr/fpcsrc@'"$out/share/fpcsrc@" -i ide/include/unix/lazbaseconf.inc
  '';

  postInstall = ''
    wrapProgram $out/bin/startlazarus --prefix NIX_LDFLAGS ' ' "'$NIX_LDFLAGS'" \
    	--prefix LCL_PLATFORM ' ' "'$LCL_PLATFORM'"
  '';

  meta = with stdenv.lib; {
    description = "Lazarus graphical IDE for FreePascal language";
    homepage = http://www.lazarus.freepascal.org;
    license = licenses.gpl2Plus ;
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
    inherit version;
  };
}
