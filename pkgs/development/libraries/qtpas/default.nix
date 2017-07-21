{ stdenv, fetchurl
, qt4 ? null, qmake4Hook ? null
, withQt5 ? false, qmake ? null, qtbase ? null, qttools ? null, qtwebkit ? null }:

let
  pver = if withQt5 then "5" else "4";
  pname = "qt${pver}pas";
  version = if withQt5 then "2.6" else "2.5";
  filename = if withQt5
    then "${pname}-V${version}Alpha_Qt5.1.1"
    else "${pname}-V${version}_Qt4.5.3";
  sha256 = if withQt5
    then "1622zg68p5k47lhaga5fxj3qd9nn36lfwqz5z2wm3gvbrmljx1r6"
    else "10l5qzgib2ax3q2p02fkra4qv86p472sd69hyq737fxs9rw44d53";

in stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  inherit version;

  src = fetchurl {
    url    = "http://users.telenet.be/Jan.Van.hijfte/qtforfpc/V${version}/splitbuild-${filename}.tar.gz";
    inherit sha256;
  };

  prePatch = if withQt5 then ''
    substituteInPlace Qt5Pas.pro \
      --replace 'QT += gui network webkitwidgets' 'QT += gui network printsupport webkitwidgets'
  '' else ''
    substituteInPlace Qt4Pas.pro \
      --replace 'target.path = $$[QT_INSTALL_LIBS]' "target.path = $out/lib"
  '';

  buildInputs = if withQt5
    then [ qtbase qtwebkit ]
    else [ qt4 ];
  nativeBuildInputs = if withQt5
    then [ qmake ]
    else [ qmake4Hook ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Free Pascal Qt${pver} Bindings for use by FPC";
    homepage    = http://users.telenet.be/Jan.Van.hijfte/qtforfpc;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
