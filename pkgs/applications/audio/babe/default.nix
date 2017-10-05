{ mkDerivation, fetchgit, lib
, qmake, extra-cmake-modules, kdoctools
, qtmultimedia, qtwebengine
, kconfig, ki18n, knotifyconfig
, taglib, youtube-dl
}:

let
  pname = "babe";
  version = "20171003";

in mkDerivation {
  name = "${pname}-${version}";

  src = fetchgit {
    url    = git://anongit.kde.org/babe.git;
    rev    = "77bd3363066f0a2b458c8a032a45c35845a8b22b";
    sha256 = "1sb3fc0r0x7naal0mma8vvpafylf4pjnay2493wa7s4iz41kh1c5";

  };

  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  propagatedBuildInputs = [
    qtmultimedia qtwebengine
    kconfig ki18n knotifyconfig
    taglib youtube-dl
  ];
  enableParallelBuilding = true;

  meta = with lib; {
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
