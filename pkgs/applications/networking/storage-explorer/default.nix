{ stdenv, fetchurl, makeWrapper, atomEnv, pkgs }:

stdenv.mkDerivation rec {
  name = "storage-explorer-${version}";
  version = "0.8.15";

  src = fetchurl {
    url = "http://download.microsoft.com/download/A/E/3/AE32C485-B62B-4437-92F7-8B6B2C48CB40/StorageExplorer-linux-x64.tar.gz";
    sha256 = "11dbq0vl1by8559642zgd62jrhl7vy4pcghgig24p65wk98drrb6";
  };

  libPath = stdenv.lib.makeLibraryPath ((with pkgs; [
    atomEnv
    # alsaLib
    # atk
    # cairo
    # cups
    # dbus
    # expat
    # ffmpeg
    # fontconfig
    # freetype
    # gnome2.GConf
    # gdk_pixbuf
    # glib
    # gtk2
    # nspr
    # nss
    # pango
    # stdenv.cc.cc.lib
  ]) ++ (with pkgs.xorg; [
    # libX11 libxcb libXrender libXScrnSaver libXtst
    # libXi libXcursor libXdamage libXrandr libXcomposite libXext libXfixes
  ]));

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    export dir=$out/lib/storage-explorer

    mkdir -p $dir
    tar -xf $src -C $dir

    runHook postUnpack
  '';

  installPhase = ''
    mkdir -p $out/bin

    ln -s $dir/StorageExplorer $out/bin/storage-explorer
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${libPath}:$dir \
      $out/opt/storage-explorer/StorageExplorer
  '';

  meta = with stdenv.lib; {
    description = "Work with Azure Storage data.";
    homepage    = https://www.storageexplorer.com;
    maintainers = with maintainers; [ peterhoeg ];
    license     = licenses.asl20;
    platforms   = platforms.linux;
  };
}
