{ stdenv, lib, fetchFromGitHub, cmake, pkgconfig, doxygen, unzip
, freetype, libjpeg, jasper, libxml2, zlib, gdal, curl, libX11
, cairo, poppler, librsvg, libpng, libtiff, libpthreadstubs, libXrandr, pcre
, xineLib, boost
, openGLPreference ? "GLVND"
, withApps ? false
, withSDL ? false, SDL
, withQt4 ? false, qt4
}:

stdenv.mkDerivation rec {
  name = "openscenegraph-${version}";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner  = "openscenegraph";
    repo   = "OpenSceneGraph";
    rev    = "OpenSceneGraph-${version}";
    sha256 = "1fbzg1ihjpxk6smlq80p3h3ggllbr16ihd2fxpfwzam8yr8yxip9";
  };

  nativeBuildInputs = [ pkgconfig cmake doxygen unzip ];

  buildInputs = [
    freetype libjpeg jasper libxml2 zlib gdal curl libX11
    cairo poppler librsvg libpng libtiff libXrandr boost
    libpthreadstubs xineLib pcre
  ] ++ lib.optional withSDL SDL
    ++ lib.optional withQt4 qt4;

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DOpenGL_GL_PREFERENCE=${openGLPreference}"
  ] ++ lib.optional (!withApps) "-DBUILD_OSG_APPLICATIONS=OFF";

  NIX_LDFLAGS = [ ] ++ lib.optional (openGLPreference == "GLVND") "-lGL";

  passthru = {
    inherit openGLPreference;
  };

  meta = with stdenv.lib; {
    description = "A 3D graphics toolkit";
    homepage = https://www.openscenegraph.org/;
    license = "OpenSceneGraph Public License - free LGPL-based license";
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
  };
}
