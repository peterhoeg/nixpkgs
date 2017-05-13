{ kdeDerivation, kdeWrapper, fetchurl, lib, cmake, extra-cmake-modules, doxygen

# For `digitaglinktree`
, perl, sqlite

, qtbase
, qtxmlpatterns
, qtsvg
, qtwebkit

, kconfigwidgets
, kcoreaddons
, kdoctools
, kfilemetadata
, knotifications
, knotifyconfig
, ktextwidgets
, kwidgetsaddons
, kxmlgui

, bison
, boost
, eigen
, exiv2
, flex
, jasper
, lcms2
, lensfun
, libgphoto2
, libkipi
, liblqr1
, libqtav
, libusb1
, marble
, mysql
, opencv
, threadweaver

# For panorama and focus stacking
, enblend-enfuse
, hugin
, gnumake

, oxygen
}:

let
  pname = "digikam";
  version =  "5.5.0";
  unwrapped = kdeDerivation rec {
    name    = "digikam-${version}";

    src = fetchurl {
      url = "mirror://kde/stable/${pname}/${name}.tar.xz";
      sha256 = "0lk2rjndfbxlkwxzviq5m72rh56b5z07fzn9xdf27fdzildvz76z"; # 5.5
      # sha256 = "0dgsgji14l5zvxny36hrfsp889fsfrsbbn9bg57m18404xp903kg"; # 5.4
    };

    nativeBuildInputs = [ cmake extra-cmake-modules ];

    patches = [ ./0001-Disable-fno-operator-names.patch ];

    propagatedBuildInputs = [
      qtbase
      qtxmlpatterns
      qtsvg
      qtwebkit

      kconfigwidgets
      kcoreaddons
      kdoctools
      kfilemetadata
      knotifications
      knotifyconfig
      ktextwidgets
      kwidgetsaddons
      kxmlgui
    ];

    buildInputs = [
      bison
      boost
      eigen
      exiv2
      flex
      jasper
      lcms2
      lensfun
      libgphoto2
      libkipi
      liblqr1
      libqtav
      libusb1
      marble.unwrapped
      mysql
      opencv
      threadweaver

      oxygen
    ];

    enableParallelBuilding = true;

    cmakeFlags = [
      "-DLIBUSB_LIBRARIES=${libusb1.out}/lib"
      "-DLIBUSB_INCLUDE_DIR=${libusb1.dev}/include/libusb-1.0"
      "-DENABLE_MYSQLSUPPORT=1"
      "-DENABLE_INTERNALMYSQL=1"
      "-DENABLE_MEDIAPLAYER=1"
    ];

    preFixup = ''
      substituteInPlace $out/bin/digitaglinktree \
        --replace "/usr/bin/perl"    "${perl}/bin/perl" \
        --replace "/usr/bin/sqlite3" "${sqlite}/bin/sqlite3"
    '';

    meta = with lib; {
      description = "Photo Management Program";
      homepage = http://www.digikam.org;
      license = licenses.gpl2;
      maintainers = with maintainers; [ the-kenny ];
      platforms = platforms.linux;
    };
  };

in kdeWrapper {
  inherit unwrapped;
  targets = [ "bin/digikam" "bin/digitaglinktree" "bin/showfoto" ];
  paths = [ gnumake hugin enblend-enfuse ];
}
