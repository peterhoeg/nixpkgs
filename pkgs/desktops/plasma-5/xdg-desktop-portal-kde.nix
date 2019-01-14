{
  mkDerivation,
  extra-cmake-modules, gettext, kdoctools, python,
  kcoreaddons, knotifications, kwayland, kwidgetsaddons,
  cups
}:

mkDerivation {
  name = "xdg-desktop-portal-kde";
  nativeBuildInputs = [ extra-cmake-modules gettext kdoctools python ];
  buildInputs = [
    cups 
    kcoreaddons knotifications kwayland kwidgetsaddons
  ];
}
