{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, installShellFiles
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
  version = "1.0.0.20220429";

  src = fetchFromGitHub {
    owner = "OpenXcom";
    repo = "OpenXcom";
    rev = "3af9628ba68fc6f35f46848f55c3beec64cd5691";
    hash = "sha256-xYpCBeHq26G7Whx9FGKeE10P7gwnH48lNz8sR31SC/g=";
  };

  nativeBuildInputs = [ cmake pkg-config installShellFiles ];

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

  postInstall = ''
    installManPage ../docs/openxcom.6
  '';

  meta = with lib; {
    description = "Open source clone of UFO: Enemy Unknown";
    homepage = "https://openxcom.org";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ cpages ];
    platforms = platforms.linux;
  };
}
