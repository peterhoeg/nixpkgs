{
  stdenv,
  lib,
  requireFile,
  fetchurl,
  innoextract,
  unzip,
}:

let
  buildGog =
    {
      fileName,
      hash,
      version,
      gameVersion,
      extraBuild ? "",
    }:
    let
      pname = "fallout-${toString gameVersion}-assets";

      dir = "share/${pname}";

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
          doc=$out/share/doc/${pname}

          mkdir -p $out/etc $dir $doc

          args=(
            --extract
            --output-dir $dir
            --lowercase
            --no-gog-galaxy
            --exclude-temp
            --color 0
            --progress 0
          )

          innoextract "''${args[@]}" $src

          mv $dir/app/* $dir

          rm -rf $dir/{__support,app,commonappdata,goggame*,savegame} $dir/*.{dll,exe}
          mv $dir/*.{cfg,ini} $out/etc
          mv $dir/*.{log,pdf,rtf,txt} $doc

        ''
        + extraBuild;

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
    extraBuild =
      let
        src = fetchurl {
          url = "https://www.moddb.com/downloads/mirror/12402/124/40df699f2e84344e3328428daf844a04";
          hash = "sha256-6SWEUULcSStYliKTKCOPdhhQ18TWcU2gmgFFzs0ojjk=";
          name = "F1ChildPatch.zip";
        };
      in
      ''
        ${lib.getExe unzip} -q -LL ${src}
        cp -r data/* $dir/data/
        cp readme* $doc
      '';
  };

  fallout2-assets-gog = buildGog rec {
    gameVersion = 2;
    version = "2.1.0.17";
    fileName = "setup_fallout2_${version}.exe";
    hash = "sha256-lXCADNegxT9HsIg6hh01TjPja5jur7xxaHR4FQNiUig=";
  };
}
