{
  kdeApp, lib, kdeWrapper,
  ecm, kdoctools,
  kparts, ktexteditor, kwidgetsaddons,
  phonon, qtserialport, qtwebkit
}:

let
  unwrapped =
    kdeApp {
      name = "marble";
      meta = { license = with lib.licenses; [ gpl2 ]; };
      nativeBuildInputs = [ ecm kdoctools ];
      buildFlags = [
        "BUILD_MARBLE_TOOLS=YES"
      ];
      propagatedBuildInputs = [
        qtserialport qtwebkit
        # kparts ktexteditor kwidgetsaddons
      ];
    };
     in
kdeWrapper unwrapped { targets = [ "bin/marble" ]; }
