{ lib, stdenv, fetchurl, steam-run, bash, coreutils
, steamRoot ? "~/.local/share/Steam"
}:

stdenv.mkDerivation {
  pname = "steamcmd";
  version = "20180104"; # According to steamcmd_linux.tar.gz mtime

  src = fetchurl {
    url = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz";
    hash = "sha256-zr8ARr/QjPRdprwJSuR6o56/QVXl7eQTc7V5uPEHHnw=";
  };

  sourceRoot = ".";

  buildInputs = [ bash steam-run ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/share/steamcmd         steamcmd.sh
    install -Dm555 -t $out/share/steamcmd/linux32 linux32/*
    install -Dm555 ${./steamcmd.sh} $out/bin/steamcmd

    substituteInPlace $out/bin/steamcmd \
      --subst-var out \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by steamRoot "${steamRoot}" \
      --subst-var-by steamRun ${steam-run}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam command-line tools";
    homepage = "https://developer.valvesoftware.com/wiki/SteamCMD";
    platforms = platforms.linux;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ tadfisher ];
  };
}
