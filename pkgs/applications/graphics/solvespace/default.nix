{ stdenv, fetchgit, cmake, pkgconfig, gettext, zlib, libpng, cairo, freetype
, json_c, fontconfig, gtkmm3, pangomm, glew, mesa_glu, xlibs, pixman, pcre
, at_spi2_core, dbus, libxkbcommon, epoxy
}:

let
  rev = "33b6e5173724ebb207c4d8450a561448b2e07e5d";

in stdenv.mkDerivation rec {
  name = "solvespace-${version}";
  version = "3.0";

  src = fetchgit {
    url = https://github.com/solvespace/solvespace;
    inherit rev;
    sha256 = "0m443kmzdp672cxxbwf36rgrn3hmgrqzx18rmc3bzwqzh0npv7i5";
    fetchSubmodules = true;
  };

  postUnpack = ''
    rm -rf extlib/{cairo,freetype,libpng,pixman,zlib}
  '';

  preConfigure = ''
    patch CMakeLists.txt <<EOF
    @@ -20,9 +20,9 @@
     # NOTE TO PACKAGERS: The embedded git commit hash is critical for rapid bug triage when the builds
     # can come from a variety of sources. If you are mirroring the sources or otherwise build when
     # the .git directory is not present, please comment the following line:
    -include(GetGitCommitHash)
    +# include(GetGitCommitHash)
     # and instead uncomment the following, adding the complete git hash of the checkout you are using:
    -# set(GIT_COMMIT_HASH 0000000000000000000000000000000000000000)
    +set(GIT_COMMIT_HASH $rev)
    EOF
  '';

  buildInputs = [
    zlib libpng cairo freetype json_c fontconfig gtkmm3 pangomm glew mesa_glu
    pixman xlibs.libpthreadstubs xlibs.libXdmcp pcre
    at_spi2_core dbus libxkbcommon epoxy
  ];
  nativeBuildInputs = [ cmake gettext pkgconfig ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A parametric 3d CAD program";
    license = licenses.gpl3;
    maintainers = with maintainers; [ edef ];
    platforms = platforms.linux;
    homepage = http://solvespace.com;
  };
}
