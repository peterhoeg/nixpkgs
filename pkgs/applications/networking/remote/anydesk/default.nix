{ stdenv, fetchurl, makeWrapper
, cairo, gdk_pixbuf, glib, gnome2, gtk2, pango, xorg
, lsb-release }:

stdenv.mkDerivation rec {
  name = "anydesk-${version}";
  version = "2.9.3";

  src = fetchurl {
    url = "https://download.anydesk.com/linux/${name}-amd64.tar.gz";
    sha256 = "01v2wyp9jrickj4w9n8nv5kaks0arrjljvqmkidwgmacjw8x7fqk";
  };

  libPath = stdenv.lib.makeLibraryPath ([
    cairo gdk_pixbuf glib gtk2 stdenv.cc.cc pango
    gnome2.gtkglext
  ] ++ (with xorg; [
    libxcb
    libX11
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXtst
  ]));

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,share/icons/hicolor,share/doc/anydesk}
    install -m755 anydesk $out/bin/anydesk
    cp changelog copyright README $out/share/doc/anydesk
    cp -r icons/* $out/share/icons/hicolor/
  '';

  postFixup = ''
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "${libPath}" \
      $out/bin/anydesk

    wrapProgram $out/bin/anydesk \
      --prefix PATH : ${stdenv.lib.makeBinPath [ lsb-release ]}
  '';

  meta = with stdenv.lib; {
    description = "Desktop sharing application, providing remote support and online meetings";
    homepage = http://www.anydesk.com;
    license = licenses.unfree;
    platforms = [ "i686-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ peterhoeg ];
  };
}
