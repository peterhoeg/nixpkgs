{ mkDerivation, lib, fetchFromGitHub, extra-cmake-modules
, qtbase, qtmultimedia, qtquickcontrol2, qttools
, libGL, libX11
, libass, openal, ffmpeg, libuchardet
, alsaLib, libpulseaudio, libva
}:

with lib;

mkDerivation rec {
  pname = "libqtav";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "wang-bin";
    repo = "QtAV";
    rev = "v${version}";
    sha256 = "sha256-4Gfy/pr90RQWWXcEbeBv/O87PZ2xyS34vYL/CS4RrpY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ extra-cmake-modules qttools ];

  buildInputs = [
    qtbase qtmultimedia qtquickcontrols2
    libGL libX11
    libass openal ffmpeg libuchardet
    alsaLib libpulseaudio libva
  ];

  # Make sure libqtav finds its libGL dependency at both link and run time
  # by adding libGL to rpath. Not sure why it wasn't done automatically like
  # the other libraries as `libGL` is part of our `buildInputs`.
  NIX_CFLAGS_LINK = "-Wl,-rpath,${libGL}/lib";

  preFixup = ''
    mkdir -p "$out/bin"
    cp -a "./bin/"* "$out/bin"
  '';

  # stripDebugList = [ "lib" "libexec" "bin" "qml" ];

  meta = {
    description = "A multimedia playback framework based on Qt + FFmpeg";
    #license = licenses.lgpl21; # For the libraries / headers only.
    license = licenses.gpl3; # With the examples (under bin) and most likely some of the optional dependencies used.
    homepage = "http://www.qtav.org/";
    maintainers = with maintainers; [ jraygauthier ];
    platforms = platforms.linux;
    # broken = !(lib.versionOlder qtbase.version "5.13");
  };
}
