{ stdenv, mkDerivation, lib, extra-cmake-modules, fetchFromGitHub, pkgconfig
, cmake, qtbase, qtdeclarative, wrapQtAppsHook
, glib, gobject-introspection, pcre, utillinux
}:

let
  cmakeShared = stdenv.mkDerivation rec {
    pname = "lirios-cmake-shared";
    version = "1.1.0";

    src = fetchFromGitHub {
      owner = "lirios";
      repo = "cmake-shared";
      rev = "v${version}";
      sha256 = "0bs17lz856frk65q9gb3lckkr0c2qi4krnp2719kdxxz9n6mjz9f";
    };

    nativeBuildInputs = [ cmake ];

    meta = with lib; {
      description = "Liri OS shared CMake functions and macros";
      license = licenses.bsd;
      inherit (src.meta) homepage;
    };
  };

in
mkDerivation rec {
  pname = "gsettings-qt";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "lirios";
    repo = "qtgsettings";
    rev = "v${version}";
    sha256 = "0pl285r1ny7l15rs4zmlff2yh7ssdxqxivxvr3az5q4b7qs743yn";
  };

  nativeBuildInputs = [
    cmake
    cmakeShared
    extra-cmake-modules
    gobject-introspection
    pkgconfig
  ];

  buildInputs = [
    glib
    pcre
    qtdeclarative
    utillinux
  ];

  meta = with lib; {
    description = "Qt/QML bindings for GSettings";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ romildo ];
    platforms = platforms.linux;
    inherit (src.meta) homepage;
  };
}
