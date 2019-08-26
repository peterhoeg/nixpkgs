{ stdenv, fetchurl, unzip, dataPath ? "/etc/rainloop" }: let

  common = { edition, sha256 }: let
    edition' = if (edition != "") then "-${edition}" else "";

  in stdenv.mkDerivation rec {
    pname = "rainloop${edition'}";
    version = "1.13.0";

    nativeBuildInputs = [ unzip ];

    sourceRoot = "rainloop";

    src = fetchurl {
      url = "https://github.com/RainLoop/rainloop-webmail/releases/download/v${version}/rainloop${edition'}-${version}.zip";
      inherit sha256;
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/rainloop
      cp -r * $out/rainloop/
      ln -s ${dataPath} $out/data

      runHook postInstall
    '';

    meta = with stdenv.lib; {
      description = "Simple, modern & fast web-based email client";
      downloadPage = "https://github.com/RainLoop/rainloop-webmail/releases";
      homepage = "https://www.rainloop.net";
      license = licenses.agpl3;
      maintainers = with maintainers; [ das_j ];
      platforms = platforms.all;
    };
  };

in {
  rainloop-community = common {
    edition = "community";
    sha256 = "1skwq6bn98142xf8r77b818fy00nb4x0s1ii3mw5849ih94spx40";
  };
  rainloop-standard = common {
    edition = "";
    sha256 = "e3ec8209cb3b9f092938a89094e645ef27659763432bedbe7fad4fa650554222";
  };
}
