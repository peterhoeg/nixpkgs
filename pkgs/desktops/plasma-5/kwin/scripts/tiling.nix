{ stdenv, lib, fetchFromGitHub
, kcoreaddons, kwindowsystem, plasma-framework, systemsettings }:

stdenv.mkDerivation rec {
  pname = "kwin-tiling";
  version = "2.2";

  src = fetchFromGitHub {
    owner  = "faho";
    repo   = "kwin-tiling";
    rev    = "v${version}";
    sha256 = "1sx64xv7g9yh3j26zxxrbndv79xam9jq0vs00fczgfv2n0m7j7bl";
  };

  buildInputs = [
    kcoreaddons kwindowsystem plasma-framework systemsettings
  ];

  dontBuild = true;

  # 1. --global still installs to $HOME/.local/share so we use --packageroot
  # 2. plasmapkg2 doesn't copy metadata.desktop into place, so we do that manually
  installPhase = ''
    runHook preInstall

    plasmapkg2 --type kwinscript --install ${src} --packageroot $out/share/kwin/scripts
    install -Dm644 ${src}/metadata.desktop $out/share/kservices5/kwin-script-tiling.desktop

    runHook postInstalll
  '';

  meta = {
    description = "Tiling script for kwin";
    inherit (src.meta) homepage;
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
