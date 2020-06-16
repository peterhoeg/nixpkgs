{ stdenv, mkDerivationWith, fetchFromGitHub, qtbase, openscenegraph, mygui, bullet, ffmpeg_3
, boost, cmake, SDL2, unshield, openal, libXt, pkgconfig }:

let
  openscenegraph_ = openscenegraph.overrideDerivation (self: {
    name = "openmw-openscenegraph-3.4.2020-04-26";

    src = fetchFromGitHub {
      owner = "OpenMW";
      repo = "osg";
      rev = "8b07809fa674ecffe77338aaea2e223b3aadff0e";
      sha256 = "0m6qrd55rqn0p0fpml8605cgrg9p4m1x37yd29781a2mbm0nz130";
    };

    cmakeFlags = self.cmakeFlags ++ [
      "-Wno-dev"
      "-DOpenGL_GL_PREFERENCE=GLVND"
    ];
  });

in mkDerivationWith stdenv.mkDerivation rec {
  version = "0.46.0";
  pname = "openmw";

  src = fetchFromGitHub {
    owner = "OpenMW";
    repo = "openmw";
    rev = "${pname}-${version}";
    sha256 = "0rm32zsmxvr6b0jjihfj543skhicbw5kg6shjx312clhlm035w2x";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ cmake boost ffmpeg_3 bullet mygui openscenegraph_ SDL2 unshield openal libXt qtbase ];

  cmakeFlags = [
    "-DDESIRED_QT_VERSION:INT=5"
  ];

  meta = with stdenv.lib; {
    description = "An unofficial open source engine reimplementation of the game Morrowind";
    homepage = "http://openmw.org";
    license = licenses.gpl3;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.linux;
  };
}
