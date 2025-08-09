{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  boost,
  doxygen,
  openssl,
  libmysqlclient,
  postgresql,
  graphviz,
  loki,
  libsForQt5,
}:

let
  qt' = libsForQt5.qt5;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "tora";
  version = "3.2.202-unstable-2024-03-03"; # https://github.com/tora-tool/tora/blob/master/NEWS

  src = fetchFromGitHub {
    owner = "tora-tool";
    repo = "tora";
    rev = "ba20ba5293b36242a8f590e50e1efd63568cb271";
    hash = "sha256-AVxyT3i689NTuMcdOQA6te4GHZ3E3P7DHiWOyXw9HDo=";
  };

  # Fixes for GCC 14
  # We cannot fetchpatch this as the paths need adjusting.
  # https://github.com/tora-tool/tora/issues/164
  patches = [ ./antlr.patch ];

  postPatch = ''
    # manual fix for https://github.com/tora-tool/tora/issues/164
    substituteInPlace extlibs/dtl/dtl/Diff.hpp \
      --replace-fail 'void enableTrivial () const {' 'void enableTrivial () {'

    substituteInPlace extlibs/libermodel/dotgraph.cpp \
      --replace-fail /usr/bin/dot ${lib.getExe' graphviz "dot"}

    substituteInPlace src/widgets/toglobalsetting.cpp \
      --replace-fail 'defaultGvHome = "/usr/bin"' 'defaultGvHome = "${lib.getBin graphviz}/bin"'
  '';

  nativeBuildInputs = [
    cmake
    qt'.qttools
    qt'.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    doxygen
    graphviz
    loki
    libmysqlclient
    openssl
    postgresql # needs libecpg, which is not available in libpq package
    libsForQt5.qscintilla
    qt'.qtbase
  ];

  cmakeFlags = [
    (lib.cmakeBool "WANT_INTERNAL_LOKI" false)
    (lib.cmakeBool "WANT_INTERNAL_QSCINTILLA" false)
    (lib.cmakeBool "ENABLE_DB2" false)
    (lib.cmakeBool "ENABLE_ORACLE" false)
    (lib.cmakeBool "ENABLE_TERADATA" false)
    # cmake/modules/FindQScintilla.cmake looks in qtbase and for the wrong library name
    (lib.cmakeFeature "QSCINTILLA_INCLUDE_DIR" "${libsForQt5.qscintilla}/include")
    (lib.cmakeFeature "QSCINTILLA_LIBRARY" "${libsForQt5.qscintilla}/lib/libqscintilla2.so")
    "-Wno-dev"
  ];

  # these libraries are only searched for at runtime so we need to force-link them
  env.NIX_LDFLAGS = "-lgvc -lmysqlclient -lecpg -lssl -L${libmysqlclient}/lib/mariadb";

  qtWrapperArgs = [
    ''--prefix PATH : ${lib.getBin graphviz}/bin''
  ];

  meta = with lib; {
    description = "Tora SQL tool";
    mainProgram = "tora";
    maintainers = with maintainers; [ peterhoeg ];
    license = licenses.asl20;
    inherit (qt'.qtbase.meta) platforms;
  };
})
