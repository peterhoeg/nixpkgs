{ stdenv, fetchFromGitHub, which
,  alsaLib, libpulseaudio, SDL2, SDL2_image }:

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
    echo ${version} > .ottdrev
  '';

  nativeBuildInputs = [ which ];

  buildInputs = [ alsaLib libpulseaudio SDL2 SDL2_image ];

  enableParallelBuilding = true;

  postInstall = ''
    mv $out/games $out/bin
  '';

  meta = with stdenv.lib; {
    description = "An open source, real time strategy game sharing game elements with the Dungeon Keeper series and Evil Genius.";
    homepage = https://github.com/OpenDUNE;
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
