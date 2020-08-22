{
  mkDerivation, lib,
  extra-cmake-modules, kdoctools,
  kcmutils, kcoreaddons, kio, kwallet
  # knotifications, kwindowsystem, kxmlgui, qtx11extras
}:

mkDerivation {
  name = "kaccounts-integration";
  meta = {
    license = with lib.licenses; [ gpl2 ];
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  buildInputs = [
    kcmutils kcoreaddons kio kwallet
    # kwindowsystem knotifications kxmlgui qtx11extras
  ];
}
