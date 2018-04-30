{ stdenv, fetchurl, glibc, libGLU_combined, freetype, glib, libSM, libICE, libXi, libXv
, libXrender, libXrandr, libXfixes, libXcursor, libXinerama, libXext, libX11, qt5
, zlib, fontconfig, dpkg, libproxy, libxml2, gstreamer, gst_all_1, dbus }:

let
  arch = {
    "x86_64-linux" = "amd64";
    "i686-linux"   = "i386";
  }."${stdenv.system}"; #  or throw "Unsupported system ${stdenv.system}";

  sha256 = {
    "amd64" = "03a973mfzz9yyvq9yhvb46p33dnds3piigcpsh114hl904kik27c";
    "i386"  = "16y3sv6cbg71r55kqdqj30szhgnsgk17jpf6j2w7qixl3n233z1b";
  }."${arch}";

  version = {
    "amd64" = "7.3.1.4507-r0";
    "i386"  = "7.3.0.3832-r0";
  }."${arch}";

  fullPath = stdenv.lib.makeLibraryPath [
    glibc
    glib
    stdenv.cc.cc
    libSM
    libICE
    libXi
    libXv
    libGLU_combined
    libXrender
    libXrandr
    libXfixes
    libXcursor
    libXinerama
    freetype
    libXext
    libX11
    zlib
    fontconfig
    libproxy
    libxml2
    gstreamer
    dbus
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];

in stdenv.mkDerivation rec {
  name = "googleearth-${version}";
  src = fetchurl {
    url = "https://dl.google.com/earth/client/current/google-earth-stable_current_${arch}.deb";
    inherit sha256;
  };

  phases = "unpackPhase installPhase";

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    dpkg-deb -x ${src} ./
  '';

  installPhase =''
    mkdir $out
    mv usr/* $out/
    rmdir usr
    mv * $out/
    rm $out/bin/google-earth-pro $out/opt/google/earth/pro/google-earth-pro
    ln -s $out/opt/google/earth/pro/googleearth $out/bin/google-earth-pro
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${fullPath}:\$ORIGIN" \
      $out/opt/google/earth/pro/googleearth-bin
    for a in $out/opt/google/earth/pro/*.so* ; do
      patchelf --set-rpath "${fullPath}:\$ORIGIN" $a
    done
  '';

  # dontPatchELF = true;

  meta = with stdenv.lib; {
    description = "A world sphere viewer";
    homepage = http://earth.google.com;
    license = licenses.unfree;
    maintainers = with maintainers; [ viric ];
    platforms = platforms.linux;
  };
}
