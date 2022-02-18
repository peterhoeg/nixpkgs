{ mkDerivation
, lib
, fetchFromGitHub
, cmake
, makeWrapper
, boost
, openssl
, libmysqlclient
, postgresql
, graphviz
, loki
, qscintilla
, qtbase
, qttools
}:

mkDerivation {
  pname = "tora";
  version = "3.2.202.20210521";

  src = fetchFromGitHub {
    owner = "tora-tool";
    repo = "tora";
    rev = "16429d82f781c40636528ec0d85f645ea859d83b";
    sha256 = "sha256-QzeD9V8C4UjVMp32m86qzq0FMHqhx3MK6Tl++YkHPEU=";
  };

  nativeBuildInputs = [ cmake makeWrapper qttools ];

  buildInputs = [
    boost
    graphviz
    loki
    libmysqlclient
    openssl
    postgresql
    qscintilla
    qtbase
  ];

  preConfigure = ''
    substituteInPlace src/widgets/toglobalsetting.cpp \
      --replace 'defaultGvHome = "/usr/bin"' 'defaultGvHome = "${lib.getBin graphviz}/bin"'
    substituteInPlace extlibs/libermodel/dotgraph.cpp \
      --replace /usr/bin/dot ${lib.getBin graphviz}/bin/dot
  '';

  cmakeFlags = [
    "-DWANT_INTERNAL_LOKI=0"
    "-DWANT_INTERNAL_QSCINTILLA=0"
    # cmake/modules/FindQScintilla.cmake looks in qtbase and for the wrong library name
    "-DQSCINTILLA_INCLUDE_DIR=${qscintilla}/include"
    "-DQSCINTILLA_LIBRARY=${qscintilla}/lib/libqscintilla2.so"
    "-DENABLE_DB2=0"
    "-DENABLE_ORACLE=0"
    "-DENABLE_TERADATA=0"
    "-Wno-dev"
  ];

  # these libraries are only searched for at runtime so we need to force-link them
  NIX_LDFLAGS = "-lgvc -lmysqlclient -lecpg -lssl";

  NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
    "-L${libmysqlclient}/lib/mysql -I${libmysqlclient}/include/mysql"
    # tora vomits warnings about deprecated declarations which for the purpose
    # of packaging is pointless and makes it incredibly hard to look for any
    # *other* warnings
    "-Wno-deprecated-declarations"
  ];

  qtWrapperArgs = [
    ''--prefix PATH : ${lib.getBin graphviz}/bin''
  ];

  meta = with lib; {
    description = "Tora SQL tool";
    license = licenses.asl20;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
