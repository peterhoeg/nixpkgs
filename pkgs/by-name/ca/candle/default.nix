{
  stdenv,
  lib,
  fetchFromGitHub,
  qtbase,
  qtserialport,
  cmake,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "candle";

  version = "1.2b.20220306";

  src = fetchFromGitHub {
    owner = "Denvi";
    repo = "Candle";
    rev = "3f763bcde1195e23ba119a5b3c70d7c889881019";
    hash = "sha256-A53rHlabcuw/nWS7jsCyVrP3CUkmUI/UMRqpogyFOCM=";
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook ];

  sourceRoot = "${finalAttrs.src.name}/src";

  installPhase = ''
    runHook preInstall

    install -Dm555 Candle $out/bin/candle

    runHook postInstall
  '';

  buildInputs = [
    qtbase
    qtserialport
  ];

  meta = with lib; {
    description = "GRBL controller application with G-Code visualizer written in Qt";
    mainProgram = "candle";
    homepage = "https://github.com/Denvi/Candle";
    license = licenses.gpl3;
    maintainers = with maintainers; [ matti-kariluoma ];
  };
})
