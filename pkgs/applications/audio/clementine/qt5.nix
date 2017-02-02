{ stdenv, fetchFromGitHub, boost, cmake, gettext, gstreamer, gst-plugins-base
, liblastfm, taglib, fftw, glew, sqlite, libgpod, libplist
, usbmuxd, libmtp, gvfs, libcdio, libspotify, protobuf, pkgconfig
, sparsehash, config, makeWrapper, runCommand, gst_plugins
, ecm, chromaprint, cryptopp, libpulseaudio, qtbase, qttools, qtwebkit, qtx11extras
}:

let
  withSpotify = config.clementine.spotify or false;

  rev = "987aa20b9d8bb85006f135c4fa3ff2a3fdeb1643";
  version = "1.3.1-${stdenv.lib.strings.substring 0 7 rev}";

  exeName = "clementine";

  src = fetchFromGitHub {
    owner  = "clementine-player";
    repo   = "Clementine";
    sha256 = "16p1aj6wcsi076fbv6hdhi1cm1rs69f74p1m0q64z82xmg3p4w5w";
    inherit rev;
  };

  patches = [
  ];

  buildInputs = [
    boost
    fftw
    gettext
    glew
    gst-plugins-base
    gstreamer
    gvfs
    libcdio
    libgpod
    liblastfm
    libmtp
    libplist
    protobuf
    sparsehash
    sqlite
    taglib
    usbmuxd

    chromaprint
    cryptopp
    libpulseaudio

    qtbase
    qttools
    qtwebkit
    qtx11extras
  ];

  nativeBuildInputs = [
    cmake
    ecm
    pkgconfig
  ];

  free = stdenv.mkDerivation {
    name = "clementine-free-${version}";
    inherit patches src buildInputs nativeBuildInputs;
    enableParallelBuilding = true;
    cmakeFlags = [
      "-DCRYPTOPP_FOUND=1"
      "-DCRYPTOPP_INCLUDE_DIRS=${cryptopp}/include"
      "-DCRYPTOPP_LIBRARIES=${cryptopp}/lib/libcryptopp.so"
    ];
    postPatch = ''
      sed -i src/CMakeLists.txt \
        -e 's,-Werror,,g' \
        -e 's,-Wno-unknown-warning-option,,g' \
        -e 's,-Wno-unused-private-field,,g'
    '';
    meta = with stdenv.lib; {
      homepage = "http://www.clementine-player.org";
      description = "A multiplatform music player";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ ttuegel ];
    };
  };

  # Spotify blob for Clementine
  blob = stdenv.mkDerivation {
    name = "clementine-blob-${version}";
    # Use the same patches and sources as Clementine
    inherit patches src nativeBuildInputs;
    buildInputs = buildInputs ++ [ libspotify ];
    # Only build and install the Spotify blob
    preBuild = ''
      cd ext/clementine-spotifyblob
    '';
    postInstall = ''
      mkdir -p $out/libexec/clementine
      mv $out/bin/clementine-spotifyblob $out/libexec/clementine
      rmdir $out/bin
    '';
    enableParallelBuilding = true;
    meta = with stdenv.lib; {
      homepage = "http://www.clementine-player.org";
      description = "Spotify integration for Clementine";
      # The blob itself is Apache-licensed, although libspotify is unfree.
      license = licenses.asl20;
      inherit (free.meta) platforms maintainers;
    };
  };

in

with stdenv.lib;

runCommand "clementine-${version}" {
  inherit free blob;
  buildInputs = [ makeWrapper ] ++ gst_plugins; # for the setup-hooks
  dontPatchELF = true;
  dontStrip = true;
  meta = {
    homepage = http://www.clementine-player.org;
    description = "A multiplatform music player"
      + " (" + (optionalString withSpotify "with Spotify, ")
      + "with gstreamer plugins: "
      + concatStrings (intersperse ", " (map (x: x.name) gst_plugins))
      + ")";
    inherit (free.meta) license platforms maintainers;
  };
}
''
  mkdir -p $out/bin
  makeWrapper "$free/bin/${exeName}" "$out/bin/${exeName}" \
      ${optionalString withSpotify "--set CLEMENTINE_SPOTIFYBLOB \"$blob/libexec/clementine\""} \
      --prefix GST_PLUGIN_SYSTEM_PATH : "$GST_PLUGIN_SYSTEM_PATH"

  mkdir -p $out/share
  for dir in applications icons kservices5; do
      ln -s "$free/share/$dir" "$out/share/$dir"
  done
''
