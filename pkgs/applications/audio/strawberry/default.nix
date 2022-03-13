{ mkDerivation
, stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, alsa-lib
, boost
, chromaprint
, fftw
, gnutls
, libcdio
, libmtp
, libpthreadstubs
, libtasn1
, libXdmcp
, ninja
, pcre
, protobuf
, sqlite
, taglib
, libpulseaudio
, libselinux
, libsepol
, p11-kit
, util-linux
, qtbase
, qtx11extras
, qttools
, withGstreamer ? true
, glib-networking
, gst_all_1
, withIpod ? false # adds about 200MB
, libgpod
, withVlc ? true
, libvlc
}:

let
  inherit (lib) optional optionals optionalString;

in
mkDerivation rec {
  pname = "strawberry";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "jonaski";
    repo = pname;
    rev = version;
    sha256 = "sha256-/pwHWmQTV1QBK+5SS0/NC6wMm2QQm+iCZArxiHjn4M4=";
  };

  buildInputs = [
    alsa-lib
    boost
    chromaprint
    fftw
    gnutls
    libcdio
    libmtp
    libpthreadstubs
    libtasn1
    libXdmcp
    pcre
    protobuf
    sqlite
    taglib
    qtx11extras
  ] ++ optionals stdenv.isLinux [
    libpulseaudio
    libselinux
    libsepol
    p11-kit
  ] ++ optionals withGstreamer (with gst_all_1; [
    glib-networking
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ])
  ++ optional withIpod libgpod
  ++ optional withVlc libvlc;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qttools
  ] ++ lib.optionals stdenv.isLinux [
    util-linux
  ];

  postInstall = optionalString withGstreamer ''
    qtWrapperArgs+=(
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
      --prefix GIO_EXTRA_MODULES : "${glib-networking.out}/lib/gio/modules"
    )
  '';

  meta = with lib; {
    description = "Music player and music collection organizer";
    homepage = "https://www.strawberrymusicplayer.org/";
    changelog = "https://raw.githubusercontent.com/jonaski/strawberry/${version}/Changelog";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ peterhoeg ];
    # upstream says darwin should work but they lack maintainers as of 0.6.6
    platforms = platforms.linux;
  };
}
