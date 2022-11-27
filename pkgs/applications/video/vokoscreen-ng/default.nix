{ lib
, mkDerivation
, fetchFromGitHub
, pkg-config
, qmake
, qttools
, gstreamer
, libX11
, pulseaudio
, qtbase
, qtmultimedia
, qtx11extras
, wayland-protocols

, gst-plugins-base
, gst-plugins-good
, gst-plugins-bad
, gst-plugins-ugly
}:

mkDerivation rec {
  pname = "vokoscreen-ng";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "vkohaupt";
    repo = "vokoscreenNG";
    rev = version;
    hash = "sha256-MisUfG4EM+ueLcTABOQXHFaFOeLhyxAapdWY81ohr4Y=";
  };

  sourceRoot = "source/src";

  nativeBuildInputs = [ qttools pkg-config qmake ];

  buildInputs = [
    gstreamer
    libX11
    pulseaudio
    qtbase
    qtmultimedia
    qtx11extras
    wayland-protocols

    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];

  postPatch = ''
    substituteInPlace vokoscreenNG.pro \
      --replace lrelease-qt5 lrelease

    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = with lib; {
    description = "User friendly Open Source screencaster for Linux and Windows";
    license = licenses.gpl2Plus;
    homepage = "https://github.com/vkohaupt/vokoscreenNG";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.linux;
  };
}
