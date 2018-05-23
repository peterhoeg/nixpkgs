{ stdenv, fetchurl, cmake
, blas, liblapack, gfortran, gmm, fltk, libjpeg
, zlib, libGLU_combined, libGLU, hdf5, xorg }:

stdenv.mkDerivation rec {
  name = "gmsh-${version}";
  version = "3.0.6";

  src = fetchurl {
    url = "http://gmsh.info/src/gmsh-${version}-source.tgz";
    sha256 = "0ywqhr0zmdhn8dvi6l8z1vkfycyv67fdrz6b95mb39np832bq04p";
  };

  # The original CMakeLists tries to use some version of the Lapack lib
  # that is supposed to work without Fortran but didn't for me.
  # patches = [ ./CMakeLists.txt.patch ];

  buildInputs = [
    blas gfortran liblapack gmm fltk hdf5 libjpeg zlib libGLU_combined libGLU
  ] ++ (with xorg; [
    libXrender libXcursor libXfixes libXext
    libXft libXinerama libX11 libSM libICE
  ]);

  nativeBuildInputs = [ cmake ];

  enableParallelBuilding = true;

  NIX_LDFLAGS = [
    "-L${gfortran}/lib"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A three-dimensional finite element mesh generator";
    homepage = http://gmsh.info/;
    license = licenses.gpl2Plus;
    platforms = platforms.all;
  };
}
