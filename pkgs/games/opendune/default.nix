{ stdenv, lib, fetchFromGitHub, pkgconfig
, libpulseaudio, SDL2, SDL2_image, SDL2_mixer }:

# - set the opendune configuration at ~/.config/opendune/opendune.ini:
#     [opendune]
#     datadir=/path/to/opendune-data
# - download dune2 into [datadir] http://www.bestoldgames.net/eng/old-games/dune-2.php

stdenv.mkDerivation rec {
  name = "opendune-${version}";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "OpenDUNE";
    repo = "OpenDUNE";
    rev = version;
    sha256 = "15rvrnszdy3db8s0dmb696l4isb3x2cpj7wcl4j09pdi59pc8p37";
  };

  postPatch = ''
pkg-config --libs-only-l libpulse
pkg-config --cflags libpulse
    #exit 1
  '';

  NIX_CFLAGS_COMPILE = [
    "-I${lib.getDev libpulseaudio}/include/pulse"
  ];

  configureFlags = [ "--with-pulse=${lib.getLib libpulseaudio}/lib/libpulse.so" ];

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ libpulseaudio SDL2 SDL2_image SDL2_mixer ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin bin/opendune
    install -Dm644 -t $out/share/doc/opendune enhancement.txt README.txt

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Dune, Reinvented";
    homepage = https://github.com/OpenDUNE/OpenDUNE;
    license = licenses.gpl2;
    maintainers = with maintainers; [ nand0p ];
  };
}
