{ stdenv, mkDerivation, fetchurl, cmake, extra-cmake-modules, pkgconfig, wrapGAppsHook
, kconfig, kcrash, kinit, kdoctools, kiconthemes, kio, kparts, kwidgetsaddons
, qtbase, qtsvg
, boost, graphviz
}:

mkDerivation rec {
  name = "kgraphviewer-${version}";
  version = "2.4.0";

  src = fetchurl {
    url = "mirror://kde/stable/kgraphviewer/${version}/${name}.tar.xz";
    sha256 = "1d1iyahdqlrgbl4pfzs7d2brf485j6pcinkcsz7h95742ijzvhl8";
  };

  buildInputs = [
    qtbase qtsvg
    boost graphviz
  ];

  nativeBuildInputs = [
    cmake extra-cmake-modules pkgconfig wrapGAppsHook
    kdoctools
  ];

  propagatedBuildInputs = [
    kconfig kinit kio kparts kwidgetsaddons
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A Graphviz dot graph viewer for KDE";
    license     = licenses.gpl2;
    maintainers = with maintainers; [ lethalman ];
    platforms   = platforms.linux;
  };
}
