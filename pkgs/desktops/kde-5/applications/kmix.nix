{
  kdeApp, lib, kdeWrapper,
  ecm, kdoctools,
  kconfig, kinit, kconfigwidgets,
  ki18n, kdelibs4support, kio, knotifications,
  knotifyconfig, kparts, kpty, kservice, ktextwidgets, kwidgetsaddons,
  kwindowsystem, kxmlgui, plasma-framework, qtscript,
  alsaLib, libcanberra_kde, libpulseaudio
}:

let
  unwrapped =
    kdeApp {
      name = "kmix";
      meta = {
        license = with lib.licenses; [ gpl2 lgpl21 fdl12 ];
        #maintainers = [ lib.maintainers.ttuegel ];
      };
      nativeBuildInputs = [ ecm kdoctools ];
      propagatedBuildInputs = [
        kconfig kinit
        kdelibs4support kconfigwidgets ki18n
        kwidgetsaddons kxmlgui
        alsaLib libcanberra_kde plasma-framework libpulseaudio
      ];
      cmakeFlags = [
        "-DKMIX_KF5_BUILD=1"
      ];
    };

in kdeWrapper {
  inherit unwrapped;
  targets = [ "bin/kmix" ];
}
