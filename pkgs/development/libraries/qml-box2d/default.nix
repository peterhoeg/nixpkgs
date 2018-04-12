{ stdenv, fetchFromGitHub, qmake
, box2d, qtquickcontrols2 }:

stdenv.mkDerivation rec {
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
}
