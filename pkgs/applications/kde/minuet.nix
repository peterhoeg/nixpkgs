{ kdeApp, lib, kdeWrapper, extra-cmake-modules, pkgconfig
, drumstick, fluidsynth
, kcoreaddons, kcrash, kdoctools
, qtquickcontrols2, qtsvg, qttools
}:

let
  unwrapped =
    kdeApp {
      name = "minuet";
      meta.license = with lib.licenses; [ lgpl21 gpl3 ];

      nativeBuildInputs = [ extra-cmake-modules pkgconfig ];
      propagatedBuildInputs = [
        drumstick fluidsynth
        kcoreaddons kcrash kdoctools
        qtquickcontrols2 qtsvg qttools
      ];

      enableParallelBuilding = true;
    };

in kdeWrapper {
  inherit unwrapped;
  targets = [ "bin/minuet" ];
  paths = [ unwrapped ];
}
