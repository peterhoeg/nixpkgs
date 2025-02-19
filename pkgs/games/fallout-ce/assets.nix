{
  stdenv,
  lib,
  requireFile,
  innoextract,
}:

let
  buildGog =
    {
      fileName,
      hash,
      version,
      gameVersion,
    }:
    let
      pname = "fallout-${toString gameVersion}-assets";

      dir = "share/${pname}";

      # manually unroll the nested MUSIC directory. Not elegant, but it's quick and it works.
      lowerCase = [
        "CRITTER.DAT"
        "MASTER.DAT"
        "DATA"
        "data/SOUND"
        "data/sound/MUSIC"
      ];

    in
    stdenv.mkDerivation (finalAttrs: {
      inherit pname version;

      src = requireFile {
        name = fileName;
        inherit hash;
        message = ''
          1. Download from GOG.com
          2. nix-prefetch-url --type sha256 file://\$(pwd)/${fileName}
        '';
      };

      nativeBuildInputs = [ (innoextract.override { withGog = true; }) ];

      buildCommand =
        ''
          dir=$out/${dir}

          mkdir -p $out/etc $dir $out/share/doc/${pname}

          args=(
            --extract
            --output-dir $dir
            --no-gog-galaxy
            --exclude-temp
            --color 0
            --progress 0
          )

          innoextract "''${args[@]}" $src

          mv $dir/app/* $dir
        ''
        + lib.concatMapStringsSep "\n" (e: ''
          test -e "$dir/${e}" && mv $dir/${e} $dir/${lib.strings.toLower e}
        '') lowerCase
        + ''
          rm -rf $dir/{__support,app,commonappdata,goggame*} $dir/*.{dll,exe}
          rm -rf $dir/data/{savegame,SAVEGAME}
          mv $dir/*.{cfg,ini} $out/etc
          mv $dir/*.{log,pdf,rtf,txt} $out/share/doc/${pname}
        '';

      passthru.baseDir = dir;

      meta = with lib; {
        description = "Game assets from GOG for use by Fallout ${toString gameVersion}.";
        license = licenses.unfree;
        maintainers = with maintainers; [ peterhoeg ];
        platforms = platforms.all;
      };
    });

in
{
  fallout1-assets-gog = buildGog rec {
    gameVersion = 1;
    version = "2.1.0.18";
    fileName = "setup_fallout_${version}.exe";
    hash = "sha256-vp3UAl7zQRfd+0/ooBUyCynA/J2jPZ8Po9vLGoRMfLk=";
  };

  fallout2-assets-gog = buildGog rec {
    gameVersion = 2;
    version = "2.1.0.17";
    fileName = "setup_fallout2_${version}.exe";
    hash = "sha256-lXCADNegxT9HsIg6hh01TjPja5jur7xxaHR4FQNiUig=";
  };
}
