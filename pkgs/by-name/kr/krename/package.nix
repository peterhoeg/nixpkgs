{
  stdenv,
  fetchurl,
  fetchFromGitLab,
  lib,
  extra-cmake-modules,
  kdePackages,
  taglib,
  exiv2,
  podofo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krename";
  version = "5.0.60";

  # src = fetchurl {
  #   url = "mirror://kde/stable/krename/${version}/src/krename-${finalAttrs.version}.tar.xz";
  #   hash = "sha256-sjxgp93Z9ttN1/VaxV/MqKVY+miq+PpcuJ4er2kvI+0=";
  # };

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "krename";
    rev = "1d7b03864d0394a77c37c57c09d1ef57b0378cd1";
    hash = "sha256-zdTg5xMNMSuDSuVBguPY/T3Pl6p+Ktv3rVckKCC9izY=";
  };

  buildInputs = with kdePackages; [
    exiv2
    podofo
    kio
    kxmlgui
    qtbase
    qtdeclarative
    qt5compat
    taglib
  ];

  nativeBuildInputs = [
    extra-cmake-modules
    kdePackages.kdoctools
    kdePackages.wrapQtAppsHook
  ];

  env.NIX_LDFLAGS = "-ltag";

  meta = with lib; {
    description = "Powerful batch renamer for KDE";
    mainProgram = "krename";
    homepage = "https://kde.org/applications/utilities/krename/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (kdePackages.qtbase.meta) platforms;
  };
})
