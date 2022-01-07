{ lib
, stdenv
, autoreconfHook
, libtool
, darwin
, fetchsvn
, pkg-config
, SDL2
}:

stdenv.mkDerivation rec {
  pname = "smpeg2";
  version = "unstable-2017-10-18";

  src = fetchsvn {
    url = "svn://svn.icculus.org/smpeg/trunk";
    rev = "413";
    sha256 = "193amdwgxkb1zp7pgr72fvrdhcg3ly72qpixfxxm85rzz8g2kr77";
  };

  patches = [
    ./hufftable-uint_max.patch
  ];

  postPatch = ''
    mv configure.in configure.ac

    sed -i configure.ac \
      -e '/AC_TYPE_SOCKLEN_T/d'

    touch AUTHORS ChangeLog NEWS

    substituteInPlace smpeg2-config.in \
      --replace @SDL_CONFIG@ ${lib.getDev SDL2}/bin/sdl2-config
  '';

  nativeBuildInputs = [ autoreconfHook libtool pkg-config ];

  buildInputs = [ SDL2 ]
    ++ lib.optional stdenv.isDarwin darwin.libobjc;

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/smpeg2-config --libs
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "SDL2 MPEG Player Library";
    homepage = "http://icculus.org/smpeg/";
    license = licenses.lgpl2;
    maintainers = with maintainers; [ orivej ];
    platforms = platforms.unix;
  };
}
