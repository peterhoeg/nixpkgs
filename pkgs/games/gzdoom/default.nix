{ stdenv, fetchFromGitHub, cmake, makeWrapper, pkgconfig
, openal, fluidsynth, soundfont-fluid, libGL, SDL2
, bzip2, zlib, libjpeg, libsndfile, mpg123, game-music-emu }:

stdenv.mkDerivation rec {
  name = "gzdoom-${version}";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner  = "coelckers";
    repo   = "gzdoom";
    rev    = "g${version}";
    sha256 = "1kjvjg218d2jk7mzlzihaa90fji4wm5zfix7ikm18wx83hcsgby3";
  };

  nativeBuildInputs = [ cmake makeWrapper pkgconfig ];

  buildInputs = [
    SDL2 libGL openal fluidsynth bzip2 zlib libjpeg libsndfile mpg123
    game-music-emu
  ];

  enableParallelBuilding = true;

  NIX_CFLAGS_LINK = [ "-lopenal" "-lfluidsynth" ];

  postPatch = ''
    substituteInPlace src/sound/mididevices/music_fluidsynth_mididevice.cpp \
      --replace libfluidsynth.so.1     libfluidsynth.so \
      --replace /usr/share/sounds/sf2/ ${soundfont-fluid}/share/soundfonts/ \
      --replace FluidR3_GM.sf2         FluidR3_GM2-2.sf2

    substituteInPlace tools/updaterevision/updaterevision.c \
      --replace '<unknown version>' '${version}'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -Dm755 gzdoom "$out/lib/gzdoom/gzdoom"
    install -Dm644 -t $out/lib/gzdoom *.pk3
    makeWrapper $out/lib/gzdoom/gzdoom $out/bin/gzdoom

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/coelckers/gzdoom;
    description = "A Doom source port based on ZDoom. It features an OpenGL renderer and lots of new features";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [ lassulus ];
  };
}
