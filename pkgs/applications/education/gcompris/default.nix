{ mkDerivation, lib, fetchurl, fetchFromGitHub, cmake, gettext, pkgconfig, qmake
, box2d
, qtbase, qtdeclarative, qtgraphicaleffects, qtmultimedia, qtquickcontrols2, qtsensors, qtsvg, qttools }:

let
  pname = "gcompris";

  qml-box2d = mkDerivation rec {
    name = "qml-box2d-${version}";
    version = "20180109";

    src = fetchFromGitHub {
      owner  = "qml-box2d";
      repo   = "qml-box2d";
      rev    = "21e57f1c0fbf6e65072c269f89d98a94ed5d7f7f";
      sha256 = "1fbsvv28b4r0szcv8bk5gxpf8v534jp2axyfp438384sy757wsq2";
    };

    postPatch = ''
      substituteInPlace box2d.pro \
        --replace '$$[QT_INSTALL_QML]' "$out/lib";
    '';

    buildInputs = [ box2d qtquickcontrols2 ];

    nativeBuildInputs = [ qmake ];

    enableParallelBuilding = true;
  };

in mkDerivation rec {
  name = "${pname}-qt-${version}";
  version = "0.90";

  src = fetchurl {
    url = "http://gcompris.net/download/qt/src/${pname}-qt-${version}.tar.xz";
    sha256 = "1i5adxnhig849qxwi3c4v7r84q6agx1zxkd69fh4y7lcmq2qiaza";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '"''${_qt_qml_system_path}/Box2D.2.0"' '"${qml-box2d}/lib/Box2D.2.0"'
  '';

  enableParallelBuilding = true;

  buildInputs = [
    qml-box2d
    qtbase qtdeclarative qtgraphicaleffects qtmultimedia qtquickcontrols2 qtsensors qtsvg
  ];

  nativeBuildInputs = [
    cmake gettext pkgconfig qttools
  ];

  meta = with lib; {
    description = "A high quality educational software suite with activities for children aged 2 to 10.";
    homepage    = https://gcompris.net;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (qtbase.meta) platforms;
  };
}
