{ stdenv, fetchFromGitHub, pkgconfig, cmake
, qtbase, openscenegraph, mygui, bullet, ffmpeg
, boost, glew, libGLU_combined, SDL2, unshield, openal, libXt }:

let
  openscenegraph_ = openscenegraph.overrideDerivation (self: {
    # requires version 3.4.x: https://wiki.openmw.org/index.php?title=Development_Environment_Setup
    src = fetchFromGitHub {
      owner  = "OpenMW";
      repo   = "osg";
      rev    = "OpenSceneGraph-3.4.1";
      sha256 = "1fbzg1ihjpxk6smlq80p3h3ggllbr16ihd2fxpfwzam8yr8yxip9";
    };
  });

in stdenv.mkDerivation rec {
  version = "0.45.0";
  name = "openmw-${version}";

  src = fetchFromGitHub {
    owner  = "OpenMW";
    repo   = "openmw";
    rev    = name;
    sha256 = "1r87zrsnza2v9brksh809zzqj6zhk5xj15qs8iq11v1bscm2a2j4";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    boost ffmpeg bullet mygui openscenegraph_ SDL2 unshield openal libXt
    glew libGLU_combined
    qtbase
  ];

  cmakeFlags = [
    "-DDESIRED_QT_VERSION:INT=5"
    "-DOpenGL_GL_PREFERENCE=LEGACY" # fails with GLVND
  ];

  meta = with stdenv.lib; {
    description = "An unofficial open source engine reimplementation of the game Morrowind";
    homepage = http://openmw.org;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
