{ stdenv, fetchFromGitHub, pkgconfig
, pidgin, json_glib, glib, http-parser } :

stdenv.mkDerivation rec {
  name = "purple-matrix-unstable-${version}";
  version = "2017-03-13";

  src = fetchFromGitHub {
    owner  = "matrix-org";
    repo   = "purple-matrix";
    rev    = "00c43fe672ef7acd497bad1dc89ec8f5b4172eb3";
    sha256 = "0w6khsqplcf4c3y8k7yx2xw6sjzbk6m4bsim8mcki78s5z6lxcrk";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ pidgin json_glib glib http-parser ];

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 -t $out/lib/pidgin/ libmatrix.so
    for size in 16 22 48; do
      install -TDm644 matrix-"$size"px.png $out/pixmaps/pidgin/protocols/$size/matrix.png
    done
  '';

  meta = with stdenv.lib; {
    description = "Matrix support for Pidgin / libpurple";
    homepage    = https://github.com/matrix-org/purple-matrix;
    license     = licenses.gpl2;
    inherit (pidgin.meta) platforms;
  };
}
