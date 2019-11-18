{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, SDL2, ftgl, libpng, libjpeg, pcre
, SDL2_image, freetype, glew, libGLU_combined, boost, glm
}:

stdenv.mkDerivation rec {
  version = "0.50";
  pname = "gource";

  src = fetchFromGitHub {
    owner = "acaudwell";
    repo = "Gource";
    rev = "gource-${version}";
    sha256 = "02lyngr16fj88x931cd9ymkmb3bx5mx68ydqnvnss0qcqvxip6ps";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [
    glew SDL2 ftgl libpng libjpeg pcre SDL2_image libGLU_combined
    boost glm freetype
  ];

  configureFlags = [ "--with-boost-libdir=${boost.out}/lib" ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A Software version control visualization tool";
    homepage = "https://gource.io/";
    license = licenses.gpl3Plus;
    longDescription = ''
      Software projects are displayed by Gource as an animated tree with
      the root directory of the project at its centre. Directories
      appear as branches with files as leaves. Developers can be seen
      working on the tree at the times they contributed to the project.

      Currently Gource includes built-in log generation support for Git,
      Mercurial and Bazaar and SVN. Gource can also parse logs produced
      by several third party tools for CVS repositories.
    '';
    maintainers = with maintainers; [ pSub ];
    platforms = platforms.unix;
  };
}
