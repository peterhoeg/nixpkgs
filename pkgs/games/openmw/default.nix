{ stdenv, lib, fetchFromGitHub, pkgconfig, cmake
, qtbase, openscenegraph_3_4, mygui, bullet, ffmpeg, tinyxml
, boost, glew, libGL, libGLU, SDL2, unshield, openal, libXt }:

let
  openscenegraph_ = openscenegraph_3_4.overrideDerivation (self: {
    # requires version 3.4.x: https://wiki.openmw.org/index.php?title=Development_Environment_Setup
    src = fetchFromGitHub {
      owner  = "OpenMW";
      repo   = "osg";
      rev    = "OpenSceneGraph-${openscenegraph_3_4.version}";
      sha256 = "1fbzg1ihjpxk6smlq80p3h3ggllbr16ihd2fxpfwzam8yr8yxip9";
    };
  });

  openGL = openscenegraph_.openGLPreference;

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
    glew libGL libGLU tinyxml
    qtbase
  ];

  cmakeFlags = [
    "-DDESIRED_QT_VERSION:INT=5"
    "-DOpenGL_GL_PREFERENCE=${openGL}"
    "-DUSE_SYSTEM_TINYXML=ON"
  ];

  NIX_LDFLAGS = [ ] ++ lib.optional (openGL == "GLVND") "-lGL";

  meta = with stdenv.lib; {
    description = "An unofficial open source engine reimplementation of the game Morrowind";
    homepage = https://openmw.org;
    license = licenses.gpl3;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.linux;
  };
}
