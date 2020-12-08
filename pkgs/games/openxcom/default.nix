{ stdenv
, fetchFromGitHub
, cmake
, pkg-config
, libGLU
, libGL
, zlib
, openssl
, libyamlcpp
, boost
, SDL
, SDL_image
, SDL_mixer
, SDL_gfx
}:

stdenv.mkDerivation {
  pname = "openxcom";
  version = "unstable-2020-12-05";

  src = fetchFromGitHub {
    owner = "OpenXcom";
    repo = "OpenXcom";
    rev = "cafc2eda3a11eefeb8e3f19f6a73d8f0d00206be";
    sha256 = "sha256-7fvczpXw1QWF0p70ZYdrFyo1LyEr7EA3mZgbexstVaw=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    SDL
    SDL_gfx
    SDL_image
    SDL_mixer
    boost
    libGL
    libGLU
    libyamlcpp
    openssl
    zlib
  ];

  meta = with stdenv.lib; {
    description = "Open source clone of UFO: Enemy Unknown";
    homepage = "https://openxcom.org";
    license = licenses.gpl3;
    maintainers = with maintainers; [ cpages ];
    platforms = platforms.linux;
  };
}
