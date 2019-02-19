{ mkDerivation, lib, fetchFromGitHub, cmake, extra-cmake-modules, makeWrapper
, boost, doxygen, openssl, mysql, postgresql, graphviz, loki, qscintilla, qtbase, qttools }:

let
  # This and the check in preConfigure is to avoid going through the entire
  # build before failing when trying to link against a non-existent library file
  # as we cannot use cmake/modules/FindQScintilla.cmake which looks in qtbase
  # and for the wrong library name
  qsctLibFile = "${qscintilla}/lib/libqscintilla2_qt5.so";

in mkDerivation rec {
  name = "tora-${version}";
  version = "3.2.176";

  src = fetchFromGitHub {
    owner  = "tora-tool";
    repo   = "tora";
    # Upstream doesn't tag point releases, so we have to find the commit of the release manually
    # https://github.com/tora-tool/tora/issues/125
    rev    = "39bf2837779bf458fc72a9f0e49271152e57829f";
    sha256 = "0fr9b542i8r6shgnz33lc3cz333fnxgmac033yxfrdjfglzk0j2k";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules makeWrapper ];

  buildInputs = [
    boost doxygen graphviz loki mysql.connector-c openssl postgresql qscintilla qtbase qttools
  ];

  preConfigure = ''
    sed -i \
      's|defaultGvHome = "/usr/bin"|defaultGvHome = "${lib.getBin graphviz}/bin"|' \
      src/widgets/toglobalsetting.cpp

    sed -i \
      's|/usr/bin/dot|${lib.getBin graphviz}/bin/dot|' \
      extlibs/libermodel/dotgraph.cpp

    if [ ! -e ${qsctLibFile} ]; then
      echo "Unable to find: ${qsctLibFile}"
      exit 1
    fi
  '';

  cmakeFlags = [
    "-DWANT_INTERNAL_LOKI=0"
    "-DWANT_INTERNAL_QSCINTILLA=0"
    "-DQSCINTILLA_INCLUDE_DIR=${qscintilla}/include"
    "-DQSCINTILLA_LIBRARY=${qsctLibFile}"
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

  NIX_CFLAGS_COMPILE = [ "-L${mysql.connector-c}/lib/mysql" "-I${mysql.connector-c}/include/mysql" ];

  qtWrapperArgs = [
    ''--prefix PATH : ${lib.getBin graphviz}/bin''
  ];

  meta = with lib; {
    description = "Tora SQL tool";
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}
