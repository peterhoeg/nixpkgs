{
  mkDerivation,
  extra-cmake-modules,
  fftw, libpthreadstubs, libXdmcp,
  frameworkintegration, kcmutils, kconfigwidgets, kcoreaddons, kdecoration,
  kguiaddons, ki18n, kwayland, kwindowsystem, plasma-framework, qtdeclarative,
  qtx11extras
}:

mkDerivation {
  name = "breeze-qt5";
  sname = "breeze";
  nativeBuildInputs = [ extra-cmake-modules ];
  propagatedBuildInputs = [
    fftw libpthreadstubs libXdmcp
    frameworkintegration kcmutils kconfigwidgets kcoreaddons kdecoration
    kguiaddons ki18n kwayland kwindowsystem plasma-framework qtdeclarative
    qtx11extras
  ];
  outputs = [ "bin" "dev" "out" ];
}
