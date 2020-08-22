{
  mkDerivation, lib,
  extra-cmake-modules, kdoctools,
  # knotifications, kwindowsystem, kxmlgui, qtx11extras
}:

mkDerivation {
  name = "kaccounts-integration";
  meta = {
    license = with lib.licenses; [ gpl2 ];
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  buildInputs = [
    # kwindowsystem knotifications kxmlgui qtx11extras
  ];
}
