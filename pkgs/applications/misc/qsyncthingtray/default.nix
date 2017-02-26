{ stdenv, lib, fetchFromGitHub, procps
, qtbase, qtwebengine, qtwebkit
, cmake, makeQtWrapper
, preferQWebView ? false }:

stdenv.mkDerivation rec {
  version = "0.5.7";
  name = "qsyncthingtray-${version}";

  src = fetchFromGitHub {
    owner = "sieren";
    repo = "QSyncthingTray";
    rev = "${version}";
    sha256 = "0crrdpdmlc4ahkvp5znzc4zhfwsdih655q1kfjf0g231mmynxhvq";
  };

  buildInputs = [ qtbase qtwebengine ] ++ lib.optional preferQWebView qtwebkit;
  nativeBuildInputs = [ cmake makeQtWrapper ];
  enableParallelBuilding = true;
  
  cmakeFlags = []
  ++ lib.optional preferQWebView "-DQST_BUILD_WEBKIT=1";

  installPhase = let qst = "qsyncthingtray"; in ''
    mkdir -p $out/bin
    install -m755 QSyncthingTray $out/bin/${qst}
    ln -s $out/bin/${qst} $out/bin/QSyncthingTray

    wrapQtProgram $out/bin/${qst} \
      ${lib.optionalString stdenv.isLinux ''
      --prefix PATH : ${procps}/bin
      ''}
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/sieren/QSyncthingTray/;
    description = "A Traybar Application for Syncthing written in C++";
    longDescription = ''
        A cross-platform status bar for Syncthing.
        Currently supports OS X, Windows and Linux.
        Written in C++ with Qt.
    '';
    license = licenses.lgpl3;
    maintainers = with maintainers; [ zraexy peterhoeg ];
    platforms = platforms.all;
  };
}
