{ stdenv, fetchFromGitHub, cmake
, qtbase, qscintilla
, bison, flex, eigen, boost, libGLU_combined, glew, opencsg, cgal
, mpfr, gmp, glib, pkgconfig, harfbuzz, gettext, pcre, libzip
}:

stdenv.mkDerivation rec {
  version = "2018.04-git";
  name = "openscad-${version}";

  src = fetchFromGitHub {
    owner = "openscad";
    repo = "openscad";
    rev = "179074dff8c23cbc0e651ce8463737df0006f4ca";
    sha256 = "1y63yqyd0v255liik4ff5ak6mj86d8d76w436x76hs5dk6jgpmfb";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    qtbase qscintilla
    bison flex eigen boost libGLU_combined glew opencsg cgal mpfr gmp glib
    harfbuzz gettext pcre libzip
  ];

  cmakeFlags = [
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "3D parametric model compiler";
    longDescription = ''
      OpenSCAD is a software for creating solid 3D CAD objects. It is free
      software and available for Linux/UNIX, MS Windows and macOS.

      Unlike most free software for creating 3D models (such as the famous
      application Blender) it does not focus on the artistic aspects of 3D
      modelling but instead on the CAD aspects. Thus it might be the
      application you are looking for when you are planning to create 3D models of
      machine parts but pretty sure is not what you are looking for when you are more
      interested in creating computer-animated movies.
    '';
    homepage = http://openscad.org/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers;
      [ bjornfor raskin the-kenny ];
  };
}
