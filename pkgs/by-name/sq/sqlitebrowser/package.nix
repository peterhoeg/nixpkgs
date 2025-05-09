{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt5,
  qt6,
  qscintilla,
  qscintilla-qt6,
  sqlcipher,
}:

let
  qt' = qt5;
  qscintilla' = if qt' == qt5 then qscintilla else qscintilla-qt6;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "sqlitebrowser";
  version = "3.13.1";

  src = fetchFromGitHub {
    owner = "sqlitebrowser";
    repo = "sqlitebrowser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bpZnO8i8MDgOm0f93pBmpy1sZLJQ9R4o4ZLnGfT0JRg=";
  };

  patches = lib.optional stdenv.hostPlatform.isDarwin ./macos.patch;

  buildInputs =
    [
      qt'.qtbase
      (qt'.qt5compat or null)
      sqlcipher
      qscintilla'
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      qt'.qtmacextras
    ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt'.qttools
    qt'.wrapQtAppsHook
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_STABLE_VERSION" true)
    (lib.cmakeBool "ENABLE_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeFeature "QSCINTILLA_INCLUDE_DIR" "${lib.getDev qscintilla'}/include")
    (lib.cmakeBool "sqlcipher" true)
  ];

  doCheck = true;

  meta = with lib; {
    description = "DB Browser for SQLite";
    mainProgram = "sqlitebrowser";
    homepage = "https://sqlitebrowser.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
})
