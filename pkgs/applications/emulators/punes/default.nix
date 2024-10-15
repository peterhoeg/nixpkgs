{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, gitUpdater
, cmake
, pkg-config
, ffmpeg
, libGLU
, alsa-lib
, libX11
, libXrandr
, sndio
, qtbase
, qtsvg
, qttools
, wrapQtAppsHook
}:

let
  inherit (lib) cmakeBool optionals;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "punes";
  version = "0.111";

  src = fetchFromGitHub {
    owner = "punesemu";
    repo = "puNES";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TIXjYkInWV3yVnvXrdHcmeWYeps5TcvkG2Xjg4roIds=";
  };

  patches = [
    # Fix FTBFS with Qt 6.7.1
    # Remove when https://github.com/punesemu/puNES/pull/403 merged & in release
    (fetchpatch {
      name = "0001-punes-Fix-compatibility-with-Qt-6.7.1.patch";
      url = "https://github.com/punesemu/puNES/commit/78c72d2dfcd570e7463a78da10904cebae6127f5.patch";
      hash = "sha256-xRalKIOb1qWgqJsFLcm7uUOblEfHDYbkukmcr4/+4Qc=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    ffmpeg
    libGLU
    qtbase
    qtsvg
  ] ++ optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libX11
    libXrandr
  ] ++ optionals stdenv.hostPlatform.isBSD [
    sndio
  ];

  cmakeFlags = [
    (cmakeBool "ENABLE_GIT_INFO" false)
    (cmakeBool "ENABLE_RELEASE" true)
    (cmakeBool "ENABLE_FFMPEG" true)
    (cmakeBool "ENABLE_OPENGL" true)
    (cmakeBool "ENABLE_QT6_LIBS" (lib.versionAtLeast qtbase.version "6.0"))
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Qt-based Nintendo Entertainment System emulator and NSF/NSFe Music Player";
    mainProgram = "punes";
    homepage = "https://github.com/punesemu/puNES";
    changelog = "https://github.com/punesemu/puNES/blob/v${finalAttrs.version}/ChangeLog";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ OPNA2608 ];
    platforms = with platforms; linux ++ freebsd ++ openbsd ++ windows;
  };
})
