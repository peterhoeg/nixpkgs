{ stdenv, fetchFromGitHub, qmakeHook
, qtbase, qttools, qtwebengine, qtx11extras, makeQtWrapper }:

stdenv.mkDerivation rec {
  name = "qupzilla-${version}";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner  = "QupZilla";
    repo   = "qupzilla";
    rev    = "v${version}";
    sha256 = "06s50hynnmb3k42a0a5jg6ql58wv19cskvnzmcmi46wcm676shgy";
  };

  buildInputs = [ qtbase qttools qtwebengine qtx11extras ];
  nativeBuildInputs = [ makeQtWrapper qmakeHook ];

  enableParallelBuilding = true;

  preConfigure = ''
    substituteInPlace src/defines.pri \
      --replace /usr/ $out/
  '';

  postFixup = ''
    wrapQtProgram $out/bin/qupzilla
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/QupZilla/qupzilla;
    description = "Qt Web Browser";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (qtbase.meta) platforms;
  };
}
