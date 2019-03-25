{ stdenv, fetchFromGitHub, cmake, pkgconfig
, libsodium, SDL2, SDL2_mixer, SDL2_ttf }:

stdenv.mkDerivation rec {
  name = "devilutionx-${version}";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner  = "diasurgical";
    repo   = "devilutionX";
    rev    = version;
    sha256 = "1ggss39k70kdndnvisawnnvrnwcg814l6y7q8nhik186c01m8knb";
  };

  postPatch = ''
    substituteInPlace SourceX/DiabloUI/diabloui.h \
      --replace SDL_ttf.h SDL2/SDL_ttf.h
  '';

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    libsodium
    SDL2 SDL2_mixer SDL2_ttf
  ];

  cmakeFlags = [
    "-DBINARY_RELEASE=ON"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=format-overflow"
  ];

  meta = with stdenv.lib; {
    description = "Diablo for modern operating systems";
    homepage = https://github.com/diasurgical/devilutionX;
    license = licenses.unfree;
    maintainers = with maintainers; [ peterhoeg ];
    hydraPlatforms = [];
  };
}
