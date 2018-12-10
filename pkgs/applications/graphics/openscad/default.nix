{ stdenv
, bison
, boost
, cgal
, double-conversion
, eigen
, fetchFromGitHub
, flex
, fontconfig
, freetype
, gettext
, glew
, glib
, gmp
, harfbuzz
, lib3mf
, libGLU, libGL
, libzip
, mkDerivation
, mpfr
, opencsg
, pcre
, pkgconfig
, qmake
, qscintilla
, qtbase
, qtmacextras
, qtmultimedia
}:

mkDerivation rec {
  pname = "openscad";
  version = "2019.05";

  src = fetchFromGitHub {
    owner = "openscad";
    repo = "openscad";
    rev = "${pname}-${version}";
    sha256 = "1qz384jqgk75zxk7sqd22ma9pyd94kh4h6a207ldx7p9rny6vc5l";
  };

  buildInputs = [
    bison flex eigen boost glew opencsg cgal mpfr gmp glib
    lib3mf libzip double-conversion freetype fontconfig pcre
    qtbase qtmultimedia qscintilla
    harfbuzz gettext pcre libzip
  ] ++ stdenv.lib.optionals stdenv.isLinux [ libGLU libGL ]
    ++ stdenv.lib.optional stdenv.isDarwin qtmacextras
  ;

  nativeBuildInputs = [ pkgconfig ];
  # nativeBuildInputs = [ bison flex pkgconfig gettext qmake ];

  cmakeFlags = [
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  # src/lexer.l:36:10: fatal error: parser.hxx: No such file or directory
  enableParallelBuilding = false; # true by default due to qmake

  postInstall = stdenv.lib.optionalString stdenv.isDarwin ''
    mkdir $out/Applications
    mv $out/bin/*.app $out/Applications
    rmdir $out/bin || true

    mv --target-directory=$out/Applications/OpenSCAD.app/Contents/Resources \
      $out/share/openscad/{examples,color-schemes,locale,libraries,fonts}

    rmdir $out/share/openscad
  '';

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
    homepage = "https://openscad.org/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ bjornfor raskin the-kenny gebner ];
    platforms = platforms.unix;
  };
}
