{
  stdenv,
  fetchFromGitLab,
  lib,
  cmake,
  pkg-config,
  kdePackages,
  libsForQt5,
  taglib,
  exiv2,
  podofo,
  preferQt6 ? true,
}:

let
  qt' = if preferQt6 then kdePackages else libsForQt5;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "krename";
  version = "5.0.60-unstable-2025-01-08";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "krename";
    rev = "83b86fa8cc6482cbf6173e262b177bbf11b71387";
    hash = "sha256-A+Zm73ecKvg1HQXxxxP0+MljE7cArnRfkz2VU9b0tlE=";
  };

  buildInputs = [
    qt'.qtbase
    (qt'.qt5compat or null) # remove when we are qt6-only
    exiv2
    podofo
    taglib
  ];

  nativeBuildInputs = [
    cmake
    qt'.extra-cmake-modules
    pkg-config
    qt'.kdoctools
    qt'.qttools
    qt'.wrapQtAppsHook
  ];

  propagatedBuildInputs = with qt'; [
    kconfig
    kcrash
    kio
    (qt'.kjsembed or null) # remove when we are qt6-only
    kxmlgui
  ];

  cmakeFlags = [
    (lib.cmakeFeature "QT_MAJOR_VERSION" (lib.versions.major qt'.qtbase.version))
    (lib.cmakeBool "BUILD_MODELSELFTEST" (finalAttrs.doCheck or false))
  ];

  # tests require a graphical environment
  doCheck = false;

  meta = with lib; {
    description = "Powerful batch renamer for KDE";
    mainProgram = "krename";
    homepage = "https://kde.org/applications/utilities/krename/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (qt'.kconfig.meta) platforms;
  };
})
