{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "loki";
  version = "0.1.7";

  src = fetchurl {
    url = "mirror://sourceforge/loki-lib/Loki/Loki%20${version}/loki-${version}.tar.gz";
    sha256 = "sha256-DxhUeFUgCc0/gqTvMDj9YIDSkzCMFaZQEoS6YJKyHPY=";
  };

  buildPhase = ''
    runHook preBuild

    substituteInPlace Makefile.common --replace /usr $out
    make build-shared

    runHook postBuild
  '';

  enableParallelBuilding = true;

  # it's noisy and last release was in 2009, so it's bound to happen - just shut
  # up the warnings.
  NIX_CFLAGS_COMPILE = map (e: "-Wno-${e}") [
    "conversion"
    "deprecated"
    "deprecated-declarations"
    "unused-local-typedefs"
  ];

  meta = with lib; {
    description = "A C++ library of designs, containing flexible implementations of common design patterns and idioms";
    homepage = "http://loki-lib.sourceforge.net";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.all;
  };
}
