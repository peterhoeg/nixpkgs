{ stdenv, fetchurl
, qmake, qtbase, qttools, qtwebkit }:

stdenv.mkDerivation rec {
  name = "qt5pas-${version}";
  version = "2.6";

  src = fetchurl {
    url    = "http://users.telenet.be/Jan.Van.hijfte/qtforfpc/V${version}/splitbuild-qt5pas-V${version}Alpha_Qt5.1.1.tar.gz";
    sha256 = "1622zg68p5k47lhaga5fxj3qd9nn36lfwqz5z2wm3gvbrmljx1r6";
  };

  prePatch = ''
    substituteInPlace Qt5Pas.pro \
      --replace 'QT += gui network webkitwidgets'   'QT += gui network printsupport webkitwidgets' \
      --replace 'target.path = $$[QT_INSTALL_LIBS]' "target.path = $out/lib"
  '';

  buildInputs = [ qtbase qtwebkit ];

  nativeBuildInputs = [ qmake ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Free Pascal Qt5 Bindings for use by FPC";
    homepage    = http://users.telenet.be/Jan.Van.hijfte/qtforfpc;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
