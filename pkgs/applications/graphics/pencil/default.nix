{ stdenv, fetchurl, dpkg, makeWrapper
, alsaLib, atk, cairo, cups, dbus, expat, fontconfig, freetype, gdk_pixbuf, glib, gnome2, gtk2, nspr, nss, pango, udev
, libX11, libXcursor, libXcomposite, libXdamage, libXext, libXfixes
, libXi, libXrandr, libXrender, libXScrnSaver, libXtst }:

stdenv.mkDerivation rec {
  version = "3.0.4";
  name = "pencil-${version}";

  src = fetchurl {
    url = "http://pencil.evolus.vn/dl/V${version}/Pencil_${version}_amd64.deb";
    sha256 = "1zb2g99nv0sr9b1nx0jrwdqp0zy835z1fkrpv0aqgshmqsabgqjq";
  };

  unpackPhase = "dpkg-deb -x $src .";
  dontBuild = true;

  nativeBuildInputs = [ dpkg makeWrapper ];

  libPath = stdenv.lib.makeLibraryPath [
    alsaLib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk_pixbuf
    glib
    gnome2.GConf
    gtk2
    nspr
    nss
    pango
    stdenv.cc.cc
    udev
    libX11 libXcursor libXcomposite libXdamage libXext libXfixes
    libXi libXrandr libXrender libXScrnSaver libXtst
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/* $out
    cp -r opt   $out

    ln -s $out/opt/Pencil/pencil $out/bin/pencil

    # sed -e "s|/usr/share/evolus-pencil|$out/share/evolus-pencil|" \
    #     -i "$out/bin/pencil"
    # sed -e "s|/usr/bin/pencil|$out/bin/pencil|" \
    #     -e "s|Icon=.*|Icon=$out/share/evolus-pencil/skin/classic/icon.svg|" \
    #     -i "$out/share/applications/pencil.desktop"

  #   wrapProgram $out/bin/pencil \
  #     --prefix PATH ":" {xulrunner}/bin
  '';

  preFixup = ''
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "${libPath}:$out/opt/Pencil" \
      $out/opt/Pencil/pencil

    for f in $out/opt/Pencil/lib*.so ; do
      patchelf \
        --set-rpath "${stdenv.lib.makeLibraryPath [ stdenv.cc.cc ]}:$out/opt/Pencil" \
        $f
      chmod 644 $f
    done
  '';

  meta = with stdenv.lib; {
    description = "GUI prototyping/mockup tool";
    homepage = https://pencil.evolus.vn/;
    license = licenses.gpl2; # Commercial license is also available
    maintainers = with maintainers; [ bjornfor prikhi ];
    platforms = platforms.linux;
  };
}
