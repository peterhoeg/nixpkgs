{ stdenv, fetchurl
, binutils, fpc, gdb, gnumake
, qt4, qt4pas, gtk2, glib, pango, atk, gdk_pixbuf
, libXi, inputproto, libX11, xproto, libXext, xextproto
, makeWrapper, tree }:

# TODO: update this to qt5 when lazarus 1.8 is released

stdenv.mkDerivation rec {
  name = "lazarus-${version}";
  version = "1.6.4";

  src = fetchurl {
    url = "mirror://sourceforge/lazarus/Lazarus%20Zip%20_%20GZip/Lazarus%20${version}/${name}-0.tar.gz";
    sha256 = "1qm56n24v8hm5hdzd0jqzqjypf5ncn4i04b5lmj4w91jmp2m8rik";
  };

  buildInputs = [
    fpc glib libXi inputproto
    qt4 qt4pas
    libX11 xproto libXext xextproto pango atk
    stdenv.cc gdk_pixbuf
  ];

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = "lazarus";

  makeFlags = with stdenv.lib; [
    "FPC=${getBin fpc}/bin/fpc"
    "PP=${getBin fpc}/bin/fpc"
    "bigide"
  ];

  installFlags = [
    "INSTALL_PREFIX=\${out}"
  ];

  NIX_DEBUG = 1;

  NIX_LDFLAGS = [
    "-L${stdenv.cc.libc}/lib"
    "-L${qt4pas}/lib"
    "-lqt4pas"
    # "-L${libX11}/lib"
    # "-lXi"
    # "-lX11"
  #   "-lglib-2.0"
  #   "-lgtk-x11-2.0"
  #   "-lgdk-x11-2.0"
  #   "-lc"
  #   "-lXext"
  #   "-lpango-1.0"
  #   "-latk-1.0"
  #   "-lgdk_pixbuf-2.0"
  #   "-lcairo"
  #   "-lgcc_s"
  ];

  preBuild = ''
    export LCL_PLATFORM=qt # update to qt5

    # echo $NIX_LDFLAGS

    # exit 1

    mkdir -p $out/{bin,lazarus,share}

    tar xf ${fpc.src} --strip-components=1 -C $out/share -m

    substituteInPlace ide/include/unix/lazbaseconf.inc \
      --replace /usr/fpcsrc $out/share/fpcsrc
    patchShebangs tools
  '';

  postInstall = ''
    wrapProgram $out/bin/startlazarus \
    	--prefix LCL_PLATFORM ' ' $LCL_PLATFORM \
      --prefix NIX_LDFLAGS  ' ' "'${stdenv.lib.concatStringsSep " " NIX_LDFLAGS}'" \
      --prefix PATH         ':' ${stdenv.lib.makeBinPath [ binutils fpc gdb gnumake ]}
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
