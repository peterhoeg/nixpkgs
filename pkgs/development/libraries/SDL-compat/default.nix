{ lib
, stdenv
, config
, fetchFromGitHub
, cmake
, pkg-config
, libGL
, libGLU
, SDL2
}:

stdenv.mkDerivation rec {
  pname = "SDL-compat";
  version = "1.2.50.20211116";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "sdl12-compat";
    rev = "d05899f95c5d7e7e2d8eee40ddf3815e53a3bddf";
    sha256 = "sha256-S2yH3wO4kDvEaRZal5ShRmdGAjDjB2WPaM19JhVt2Qk=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libGL libGLU SDL2 ];

  meta = with lib; {
    description = "A cross-platform multimedia library";
    homepage = "http://www.libsdl.org/";
    license = licenses.zlib;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
