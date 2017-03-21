{ kdeApp, lib, extra-cmake-modules, qtbase
, alsaLib, kdelibs4support, kdoctools, libkcddb, solid }:

kdeApp {
  name = "libkcompactdisc";
  meta = with lib; {
    license = with licenses; [ gpl2 lgpl21 bsd3 ];
    maintainers = with maintainers; [ peterhoeg ];
  };
  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [ alsaLib ];
  propagatedBuildInputs = [ kdelibs4support kdoctools libkcddb solid ];
}
