{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cppunit,
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
  # there is a qt6 branch upstream, but it hasn't seen any activity since 2022
  qt' = libsForQt5;
  gvBin = "${lib.getBin graphviz}/bin";

  dtl = fetchFromGitHub {
    owner = "cubicdaiya";
    repo = "dtl";
    tag = "v1.21";
    hash = "sha256-s+syRiJhcxvmE0FBcbCi6DrL1hwu+0IJNMgg5Tldsv4=";
  };

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
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 3.1 FATAL_ERROR)" "cmake_minimum_required(VERSION ${cmake.version})"

    rm -rf extlibs/dtl
    ln -s ${dtl} extlibs/dtl

    substituteInPlace extlibs/libermodel/dotgraph.cpp \
      --replace-fail /usr/bin/dot ${gvBin}/dot

    substituteInPlace src/core/toglobalconfiguration.cpp \
      --replace-fail 'GvDir("/usr/bin")' 'GvDir("${gvBin}")'

    substituteInPlace src/widgets/toglobalsetting.cpp \
      --replace-fail 'defaultGvHome = "/usr/bin"' 'defaultGvHome = "${gvBin}"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    cppunit
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
    qt'.qscintilla
    qt'.qtbase
  ];

  cmakeFlags = [
    (lib.cmakeBool "WANT_INTERNAL_LOKI" false)
    (lib.cmakeBool "WANT_INTERNAL_QSCINTILLA" false)
    (lib.cmakeBool "ENABLE_DB2" false) # we don't have the libraries
    (lib.cmakeBool "ENABLE_ORACLE" false) # we don't have the libraries
    (lib.cmakeBool "ENABLE_TERADATA" false) # we don't have the libraries
    (lib.cmakeFeature "LIB_SUFFIX" "64")
    # cmake/modules/FindQScintilla.cmake looks in qtbase and for the wrong library name as it doesn't use pkg-config
    (lib.cmakeFeature "QSCINTILLA_INCLUDE_DIR" "${qt'.qscintilla}/include")
    (lib.cmakeFeature "QSCINTILLA_LIBRARY" "${qt'.qscintilla}/lib/libqscintilla2.so")
    "-Wno-dev"
  ];

  # these libraries are only searched for at runtime so we need to force-link them
  env.NIX_LDFLAGS = "-lgvc -lmysqlclient -lecpg -lssl -L${libmysqlclient}/lib/mariadb";

  # tests are only built in development mode and then only if USE_EXPERIMENTAL is set
  doCheck = false;

  meta = {
    description = "Tora SQL tool";
    mainProgram = "tora";
    maintainers = with lib.maintainers; [ peterhoeg ];
    license = lib.licenses.asl20;
    inherit (qt'.qtbase.meta) platforms;
  };
})
