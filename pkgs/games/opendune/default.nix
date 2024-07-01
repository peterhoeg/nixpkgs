{ stdenv
, lib
, fetchFromGitHub
, gawk
, pkg-config
, writeScriptBin
, alsa-lib
, libpulseaudio
, SDL2
, SDL2_image
}:

# - set the opendune configuration at ~/.config/opendune/opendune.ini:
#     [opendune]
#     datadir=/path/to/opendune-data
# - download dune2 into [datadir] https://www.bestoldgames.net/eng/old-games/dune-2.php

let
  inherit (lib) concatStringsSep getExe getLib;

  rev = "0626d4f533798c667e365955fc2d7a50b94f97cd";

  # https://github.com/OpenDUNE/OpenDUNE/blob/master/findversion.sh
  vers = writeScriptBin "findversion.sh" ''
    echo -e "${concatStringsSep "\\t" (map toString [ "" "" 0 rev ])}"
  '';

in
stdenv.mkDerivation (_finalAttrs: {
  pname = "opendune";
  version = "0.9.20210826";

  src = fetchFromGitHub {
    owner = "OpenDUNE";
    repo = "OpenDUNE";
    inherit rev;
    hash = "sha256-ObptehpICsRwE8LgaVnHh+wBOAds7y4eTsOnfBjSznI=";
  };

  postPatch = ''
    # to avoid sleeping during the configure phase
    touch .ottdrev
    # ensure we can detect the proper version
    ln -sf ${getExe vers} ./findversion.sh
  '';

  configureFlags = [
    "--enable-lto"
    "--with-alsa=${getLib alsa-lib}/lib/libasound.so"
    "--with-pulse=${getLib libpulseaudio}/lib/libpulse.so"
  ];

  nativeBuildInputs = [ gawk pkg-config ];

  buildInputs = [ alsa-lib libpulseaudio SDL2 SDL2_image ];

  env.NIX_CFLAGS_COMPILE = concatStringsSep " " [
    "-Wno-format-overflow"
    "-Wno-redundant-decls"
    "-Wno-stringop-truncation"
    "-Wno-unused-but-set-variable"
    "-Wno-unused-function"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin bin/opendune
    install -Dm444 -t $out/share/doc/opendune *.txt

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dune, Reinvented";
    mainProgram = "opendune";
    homepage = "https://github.com/OpenDUNE/OpenDUNE";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ peterhoeg ];
  };
})
