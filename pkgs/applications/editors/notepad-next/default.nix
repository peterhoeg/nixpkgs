{ stdenv
, lib
, fetchFromGitHub
, qmake
, qtbase
, qt5compat
, qttools
, wrapQtAppsHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "notepad-next";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "dail8859";
    repo = "NotepadNext";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I2bS8oT/TGf6fuXpTwOKo2MaUo0jLFIU/DfW9h1toOk=";
    # External dependencies - https://github.com/dail8859/NotepadNext/issues/135
    fetchSubmodules = true;
  };

  sourceRoot = "source/src";

  nativeBuildInputs = [ qmake qttools wrapQtAppsHook ];

  buildInputs = [ qtbase qt5compat ];

  env.LANG = "C.UTF-8";

  postPatch = ''
    substituteInPlace i18n.pri \
      --replace-fail 'EXTRA_TRANSLATIONS = \' "" \
      --replace-fail '$$[QT_INSTALL_TRANSLATIONS]/qt_zh_CN.qm' ""
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mv $out/bin $out/Applications
    rm -fr $out/share
  '';

  meta = with lib; {
    homepage = "https://github.com/dail8859/NotepadNext";
    description = "Cross-platform, reimplementation of Notepad++";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sebtm ];
    broken = stdenv.hostPlatform.isAarch64;
    mainProgram = "NotepadNext";
  };
})
