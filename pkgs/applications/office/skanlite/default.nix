{ lib, mkDerivation, fetchurl, cmake, extra-cmake-modules, qtbase,
  kcoreaddons, kdoctools, ki18n, kio, kxmlgui, ktextwidgets,
  libksane
}:

mkDerivation rec {
  pname = "skanlite";
  version = "2.2.0";

  src = fetchurl {
    url = "mirror://kde/stable/skanlite/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1r44spfxr4ikcx9k1gipvcylhp92i93azxss44bswysljwwwrzjl";
  };

  nativeBuildInputs = [ cmake kdoctools extra-cmake-modules ];

  buildInputs = [
    qtbase
    kcoreaddons kdoctools ki18n kio kxmlgui ktextwidgets
    libksane
  ];

  cmakeFlags = [
    "-Wno-dev"
  ];

  meta = with lib; {
    description = "KDE simple image scanning application";
    homepage    = "http://www.kde.org/applications/graphics/skanlite/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ pshendry ];
    platforms   = platforms.linux;
  };
}
