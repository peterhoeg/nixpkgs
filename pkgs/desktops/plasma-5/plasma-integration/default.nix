{
  mkDerivation,
  extra-cmake-modules,
  breeze-qt5, kconfig, kconfigwidgets, kiconthemes, kio, knotifications,
  kwayland, libXcursor, qtquickcontrols2, qqc2-desktop-style
}:

# TODO: install Noto Sans and Oxygen Mono fonts with plasma-integration

mkDerivation {
  name = "plasma-integration";
  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [
    breeze-qt5 kconfig kconfigwidgets kiconthemes kio knotifications kwayland
    libXcursor qtquickcontrols2 qqc2-desktop-style
  ];
}
