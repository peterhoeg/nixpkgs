{
  cmake,
  coreutils,
  findutils,
  fpattern,
  lib,
  makeDesktopItem,
  sdl2-compat,
  sdl3,
  resholve,
  runtimeShell,
  stdenv,
  symlinkJoin,
  xorg,

  pname,
  version,
  gameVersion ? 1,
  icon ? null,
  src,
  patches ? [ ],
  buildInputs ? [ ],
  meta,
  assets ? [ ], # you might want to provide additional assets
}:

let
  hasAssets = assets != [ ];

  script =
    resholve.writeScriptBin pname
      {
        scripts = [ "bin/${pname}" ];
        interpreter = runtimeShell;
        inputs = [
          "${binary}/libexec"
          coreutils
          findutils
          xorg.lndir
        ];
        execer = [ "cannot:${binary}/libexec/${pname}" ];
      }

      ''
          set -eEuo pipefail

          assetDir="''${XDG_DATA_HOME:-$HOME/.local/share}/${pname}"
          [ -d "$assetDir" ] || mkdir -p "$assetDir"
          pushd "$assetDir" >/dev/null

          ${lib.optionalString hasAssets ''
            link_assets() {
              local asset; asset="$1"

              lndir -silent "$asset" "$assetDir"

              for cfgFile in $asset/etc/*; do
                test -e "$cfgFile" || continue

                name="$(basename "$cfgFile")"
                test -f "$name" && continue
                install -Dm644 "$cfgFile" "$name"
              done
            }

            find "$assetDir" -lname '/nix/store/*' -type l -delete

            ${lib.concatMapStringsSep "\n" (e: ''
              link_assets "${e}/${e.baseDir}"
            '') assets}
          ''}

          notice=0 fault=0
          requiredFiles=(master.dat critter.dat)
          for f in "''${requiredFiles[@]}"; do
            if [ ! -f "$f" ]; then
              echo "Required file $f not found in $PWD, note the files are case-sensitive"
              notice=1 fault=1
            fi
          done

          if [ ! -d "data/sound/music" ]; then
            echo "data/sound/music directory not found in $PWD. This may prevent in-game music from functioning."
            notice=1
          fi

          if [ "''${SDL_VIDEODRIVER:-}" = "wayland" ]; then
            echo "There may be issues running with SDL_VIDEODRIVER=wayland. You may want to unset this."
            notice=1
          fi

          if [ $notice -ne 0 ]; then
            echo "Please reference the installation instructions at ${meta.homepage}"
          fi

          if [ $fault -ne 0 ]; then
            exit $fault;
          fi

        exec ${pname} "$@"
      '';

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Fallout ${toString gameVersion} CE";
    exec = lib.getExe script;
    icon = if (icon != null) then icon else pname;
    categories = [ "Game" ];
  };

  binary = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      patches
      ;

    nativeBuildInputs = [ cmake ];

    buildInputs = [
      sdl2-compat
      sdl3
      fpattern
    ] ++ buildInputs;

    hardeningDisable = [ "format" ];

    postPatch = ''
      substituteInPlace third_party/fpattern/CMakeLists.txt \
        --replace-fail "FetchContent_Populate" "#FetchContent_Populate" \
        --replace-fail "{fpattern_SOURCE_DIR}" "${lib.getDev fpattern}/include" \
        --replace-fail "$/nix/" "/nix/"
    '';

    installPhase = ''
      runHook preInstall

      install -Dm555 ${pname} $out/libexec/${pname}
      install -Dm444 -t $out/share/doc/${pname} ../*.md

      runHook postInstall
    '';

    meta = meta';
  };

  meta' =
    with lib;
    {
      description = "Fully working re-implementation of Fallout ${toString gameVersion}";
      longDescription = ''
        It has the same original gameplay, engine bugfixes, and some quality of life improvements
      '';
      license = licenses.sustainableUse;
      maintainers = with maintainers; [
        hughobrien
        peterhoeg
      ];
      platforms = platforms.linux;
      mainProgram = pname;
    }
    // meta;

in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    binary
    desktopItem
    script
  ];
  meta = meta';
}
