{ kdeDerivation, kdeWrapper, fetchgit, lib
, extra-cmake-modules, kdoctools
, qca-qt5, qjson, qtwebkit
, kcmutils, kconfig, kdelibs4support, kdnssd, kinit, knewstuff, knotifyconfig, ktexteditor
, plasma-framework, threadweaver
, curl, ffmpeg, gdk_pixbuf, libaio, libmtp, loudmouth, lzo, lz4, mariadb, snappy, taglib, taglib_extras
}:

let
  pname = "amarok";
  version = "2.8.91-20170228";
  unwrapped = kdeDerivation rec {
    name = "${pname}-${version}";

    # this should go back to the regular KDE mirror when the kf5 branch is merged into master
    src = fetchgit {
      url    = git://anongit.kde.org/amarok.git;
      rev    = "323e2d5b43245c4c06e0b83385d37ef0d32920cb";
      sha256 = "05w7kl6qfmkjz0y1bhgkkbmsqdll30bkjd6npkzvivrvp7dplmbh";
    };

    meta = with lib; {
      license = licenses.gpl2;
      maintainers = with maintainers; [ peterhoeg ];
    };

    nativeBuildInputs = [ extra-cmake-modules kdoctools ];
    propagatedBuildInputs = [
      qca-qt5 qjson qtwebkit
      kcmutils kconfig kdelibs4support kdnssd kinit knewstuff knotifyconfig ktexteditor
      plasma-framework threadweaver
      curl ffmpeg gdk_pixbuf libaio libmtp loudmouth lz4 lzo mariadb snappy taglib taglib_extras
    ];
    enableParallelBuilding = true;
  };

in kdeWrapper {
  inherit unwrapped;
  targets = map (b: "bin/" + b)
    [ "amarok" "amarok_afttagger" "amarokcollectionscanner" ];
}
