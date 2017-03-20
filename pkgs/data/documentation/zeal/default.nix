{ stdenv, fetchFromGitHub, cmake, extra-cmake-modules, pkgconfig
, libarchive, libpthreadstubs, xorg ? null
, qtbase, qtimageformats, qtwebkit, qtx11extras, makeQtWrapper }:

let
  withX = stdenv.isLinux;

in stdenv.mkDerivation rec {
  name = "zeal-${version}";
  version = "0.3.1.1";

  src = fetchFromGitHub {
    owner  = "zealdocs";
    repo   = "zeal";
    # rev    = "v${version}";
    rev    = "c6003e19b93cf45ba96d06b2e7b68efe88c501a3";
    sha256 = "04q1m9ckqs8l6kha95cv8013wfqyi0p16c7dx0gkglpm18azadb7";
  };

  buildInputs = [
    libarchive libpthreadstubs
    qtbase qtimageformats qtwebkit qtx11extras
  ] ++ stdenv.lib.optionals withX (with xorg; [ xcbutilkeysyms libXdmcp ]);

  nativeBuildInputs = [ cmake extra-cmake-modules makeQtWrapper pkgconfig ];

  enableParallelBuilding = true;

  postFixup = ''
    wrapQtProgram $out/bin/zeal
  '';

  meta = with stdenv.lib; {
    description = "A simple offline API documentation browser";
    longDescription = ''
      Zeal is a simple offline API documentation browser inspired by Dash (OS X
      app), available for Linux, xBSD and Windows.
    '';
    homepage = http://zealdocs.org/;
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ skeidel peterhoeg ];
  };
}
