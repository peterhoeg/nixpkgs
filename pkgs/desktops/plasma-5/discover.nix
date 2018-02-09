{
  mkDerivation,
  extra-cmake-modules, gettext, kdoctools, python,
  appstream, appstream-qt, packagekit-qt,
  qtquickcontrols2,
  karchive, kconfig, kcrash, kdbusaddons, kdeclarative, kio, kirigami2, kitemmodels,
  knewstuff, kwindowsystem, kxmlgui, plasma-framework
}:

mkDerivation {
  name = "discover";
  nativeBuildInputs = [ extra-cmake-modules gettext kdoctools python ];
  buildInputs = [
    appstream appstream-qt packagekit-qt
    qtquickcontrols2
    karchive kconfig kcrash kdbusaddons kdeclarative kio kirigami2 kitemmodels knewstuff kwindowsystem kxmlgui
    plasma-framework
  ];
}
