{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dcfldd";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "resurrecting-open-source-projects";
    repo = "dcfldd";
    tag = "v" + finalAttrs.version;
    hash = "sha256-IRyc57UBsUgW8WALRhYSvT1rKIt27PBiT7MWCPJL0mY=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Enhanced version of GNU dd";
    homepage = "https://github.com/resurrecting-open-source-projects/dcfldd";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ qknight ];
    mainProgram = "dcfldd";
  };
})
