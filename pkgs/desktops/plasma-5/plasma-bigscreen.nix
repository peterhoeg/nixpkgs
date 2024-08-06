{ mkDerivation
, extra-cmake-modules
, kactivities
, kactivities-stats
, plasma-framework
, ki18n
, kirigami2
, kdeclarative
, kcmutils
, knotifications
, kio
, kwayland
, kwindowsystem
, plasma-workspace
, qtmultimedia
}:
mkDerivation {
  pname = "plasma-bigscreen";
  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [
    kactivities
    kactivities-stats
    plasma-framework
    ki18n
    kirigami2
    kdeclarative
    kcmutils
    knotifications
    kio
    kwayland
    kwindowsystem
    plasma-workspace
    qtmultimedia
  ];

  postPatch = ''
    substituteInPlace bin/plasma-bigscreen-wayland.in \
      --replace @KDE_INSTALL_FULL_LIBEXECDIR@ "${plasma-workspace}/libexec" \

    for f in bin/plasma-bigscreen-*.desktop.cmake; do
      substituteInPlace $f \
        --replace dbus-run-session ${plasma-workspace}/libexec/plasma-dbus-run-session-if-needed
    done
  '';

  preFixup = ''
    wrapQtApp $out/bin/plasma-bigscreen-x11
    wrapQtApp $out/bin/plasma-bigscreen-wayland
  '';

  passthru.providedSessions = [ "plasma-bigscreen-x11" "plasma-bigscreen-wayland" ];
}
