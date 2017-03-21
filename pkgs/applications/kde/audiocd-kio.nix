{ kdeApp, lib, extra-cmake-modules, qtbase
, kcodecs, kio, kdoctools, kwidgetsaddons, solid }:

kdeApp {
  name = "audiocd-kio";
  meta = with lib; {
    license = with licenses; [ gpl2 lgpl21 bsd3 ];
    maintainers = with maintainers; [ peterhoeg ];
  };
  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [ ];
  propagatedBuildInputs = [ kio ];
}
