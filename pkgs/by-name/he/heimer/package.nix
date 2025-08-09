{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libsForQt5,
  qt6Packages,
  qtVersion ? 6,
}:

let
  qt =
    {
      _5 = libsForQt5;
      _6 = qt6Packages;
    }
    ."_${builtins.toString qtVersion}";

in
stdenv.mkDerivation (finalAttrs: {
  pname = "heimer";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "juzzlin";
    repo = "heimer";
    rev = finalAttrs.finalPackage.version;
    hash = "sha256-eKnGCYxC3b7qd/g2IMDyZveBg+jvFA9s3tWEGeTPSkU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt.wrapQtAppsHook
  ];

  buildInputs = [
    qt.qttools
    qt.qtbase
  ];

  cmakeFlags = [
    "-Wno-dev"
    (lib.cmakeBool "BUILD_TESTS" (finalAttrs.finalPackage.doCheck or false))
    (lib.cmakeBool "BUILD_WITH_QT6" (qtVersion == 6))
  ];

  env.LANG = "C.UTF-8";

  meta = {
    description = "Simple cross-platform mind map and note-taking tool written in Qt";
    mainProgram = "heimer";
    homepage = "https://github.com/juzzlin/Heimer";
    changelog = "https://github.com/juzzlin/Heimer/blob/${finalAttrs.finalPackage.version}/CHANGELOG";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
})
