{
  kdeApp, lib, kdeWrapper,
  ecm, kdoctools,
  kglobalaccel, kxmlgui, kcoreaddons, kdelibs4support,
  plasma-framework, libcanberra_kde, libpulseaudio, alsaLib
}:

let
  unwrapped =
    kdeApp {
      name = "kmix";
      meta = {
        license = with lib.licenses; [ gpl2 lgpl21 fdl12 ];
        maintainers = [ lib.maintainers.peterhoeg ];
      };
      nativeBuildInputs = [ ecm kdoctools ];
      buildInputs = [ libcanberra_kde libpulseaudio alsaLib ];
      propagatedBuildInputs = [
        kglobalaccel kxmlgui kcoreaddons kdelibs4support
        plasma-framework
      ];
      cmakeFlags = [
        "-DKMIX_KF5_BUILD=1"
      ];
    };

in kdeWrapper {
  inherit unwrapped;
  targets = [ "bin/kmix" ];
}
