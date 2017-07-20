{ stdenv, fetchurl, dpkg, makeWrapper, atomEnv, ffmpeg
, alsaLib, atk, cairo, cups, dbus, expat, fontconfig, freetype, gdk_pixbuf, glib, gnome2, gtk2, nspr, nss, pango, udev
, libX11, libXcursor, libXcomposite, libXdamage, libXext, libXfixes
, libXi, libXrandr, libXrender, libXScrnSaver, libXtst }:

let
  plat = {
    "x86_64-linux" = "amd64";
  }."${stdenv.system}";

  sha256 = {
    "x86_64-linux" = "1zb2g99nv0sr9b1nx0jrwdqp0zy835z1fkrpv0aqgshmqsabgqjq";
  }."${stdenv.system}";

in stdenv.mkDerivation rec {
  version = "3.0.4";
  name = "pencil-${version}";

  src = fetchurl {
    url = "http://pencil.evolus.vn/dl/V${version}/Pencil_${version}_${plat}.deb";
    inherit sha256;
  };

  unpackPhase = "dpkg-deb -x $src .";
  dontBuild = true;

  nativeBuildInputs = [ dpkg makeWrapper ];

  libPath = stdenv.lib.concatStringsSep ":" [
    atomEnv.libPath
    "${stdenv.lib.makeLibraryPath [ ffmpeg ]}"
    "$out/lib/pencil"
  ];

  # libPath = stdenv.lib.makeLibraryPath [
  #   alsaLib
  #   atk
  #   cairo
  #   cups
  #   dbus
  #   expat
  #   fontconfig
  #   freetype
  #   gdk_pixbuf
  #   glib
  #   gnome2.GConf
  #   gtk2
  #   nspr
  #   nss
  #   pango
  #   stdenv.cc.cc
  #   udev
  #   libX11 libXcursor libXcomposite libXdamage libXext libXfixes
  #   libXi libXrandr libXrender libXScrnSaver libXtst
  # ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/pencil}
    cp -r usr/* $out
    cp -r opt/Pencil/* $out/lib/pencil/

    ln -s $out/lib/pencil/pencil $out/bin/pencil

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
      --set-rpath "${libPath}" \
      $out/lib/pencil/pencil

  #   for f in $out/opt/Pencil/lib*.so ; do
  #     patchelf \
  #       --set-rpath "${stdenv.lib.makeLibraryPath [ stdenv.cc.cc ]}:$out/opt/Pencil" \
  #       $f
  #     chmod 644 $f
  #   done
  '';

  meta = with stdenv.lib; {
    description = "GUI prototyping/mockup tool";
    homepage = https://pencil.evolus.vn/;
    license = licenses.gpl2; # Commercial license is also available
    maintainers = with maintainers; [ bjornfor prikhi ];
    platforms = platforms.linux;
  };
}
