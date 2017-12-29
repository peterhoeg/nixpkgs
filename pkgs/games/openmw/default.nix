{ stdenv, fetchFromGitHub, cmake, pkgconfig
, qtbase, openscenegraph, mygui, bullet, ffmpeg, boost, SDL2, unshield, openal
, glib, pcre
, giflib, libpthreadstubs, libXt }:

let
  openscenegraph_ = openscenegraph.overrideDerivation (self: {
    src = fetchFromGitHub {
      owner  = "OpenMW";
      repo   = "osg";
      rev    = "b6ec7bb7a4cd06ae95bda087d48c0fb7d5ca0abf";
      sha256 = "0j33wvrmy1ncrn4s7xznpy6qbarlaninil8da9xgpkh9lr7hj2bw";
    };
  });

in stdenv.mkDerivation rec {
  version = "0.43.0";
  name = "openmw-${version}";

  src = fetchFromGitHub {
    owner  = "OpenMW";
    repo   = "openmw";
    rev    = name;
    sha256 = "1nybxwp77qswjayf0g9xayp4x1xxq799681rhjlggch127r07ifi";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    cmake pkgconfig
  ];

  buildInputs = [
    qtbase
    libpthreadstubs libXt
    boost bullet ffmpeg glib mygui openal openscenegraph_ pcre SDL2 unshield
  ];

  meta = with stdenv.lib; {
    description = "An unofficial open source engine reimplementation of the game Morrowind";
    homepage    = http://openmw.org;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ abbradar ];
    platforms   = platforms.linux;
  };
}
