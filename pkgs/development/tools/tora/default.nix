{ mkDerivation, lib, fetchFromGitHub, cmake, extra-cmake-modules, makeWrapper
, boost, doxygen, openssl, mysql, postgresql, graphviz, loki, qscintilla, qtbase, qttools }:

let
  qscintillaLib = (qscintilla.override { withQt5 = true; });
  sofile = "${qscintillaLib}/lib/libqscintilla2_qt5.so";

in mkDerivation rec {
  name = "tora-${version}";
  version = "3.2";

  src = fetchFromGitHub {
    owner  = "tora-tool";
    repo   = "tora";
    rev    = "v${version}";
    sha256 = "1qy4p770rfzjx9ypncnc5ziggs61v6478n8l8dk2hz199j2w3n9h";
  };

  nativeBuildInputs = [ cmake doxygen makeWrapper qttools ]; # extra-cmake-modules

  buildInputs = [
    boost graphviz loki mysql.connector-c openssl postgresql qscintillaLib qtbase
  ];

  postPatch = ''
    substituteInPlace src/widgets/toglobalsetting.cpp --replace \
      'defaultGvHome = "/usr/bin"' 'defaultGvHome = "${lib.getBin graphviz}/bin"'

    substituteInPlace extlibs/libermodel/dotgraph.cpp --replace \
      /usr/bin/dot ${lib.getBin graphviz}/bin/dot
  '';

  # the qscintilla library has changed name a few times, so bail early if it doesn't exist
  preBuild = ''
    if [[ ! -e ${sofile} ]] ; then
      echo "${sofile} not found. Aborting!"
      exit 1
    fi
  '';

  cmakeFlags = [
    "-DWANT_INTERNAL_LOKI=0"
    "-DWANT_INTERNAL_QSCINTILLA=0"
    # cmake/modules/FindQScintilla.cmake looks in qtbase and for the wrong library name
    "-DQSCINTILLA_INCLUDE_DIR=${qscintillaLib}/include"
    "-DQSCINTILLA_LIBRARY=${sofile}"
    "-DENABLE_DB2=0"
    "-DENABLE_ORACLE=0"
    "-DENABLE_TERADATA=0"
    "-DQT5_BUILD=1"
    "-Wno-dev"
  ];

  # these libraries are only searched for at runtime so we need to force-link them
  NIX_LDFLAGS = [
    "-lgvc"
    "-lmysqlclient"
    "-lecpg"
    "-lssl"
  ];

  NIX_CFLAGS_COMPILE = [
    "-L${mysql.connector-c}/lib/mysql"
    "-I${mysql.connector-c}/include/mysql"
  ];

  postFixup = ''
    wrapProgram $out/bin/tora \
      --prefix PATH : ${lib.makeBinPath [ graphviz ]}
  '';

  meta = with lib; {
    description = "Tora SQL tool";
    license = licenses.asl20;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
