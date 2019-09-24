{ stdenv, fetchurl, requireFile, makeWrapper
, dxx-rebirth, descent1-assets, descent2-assets }:

let
  generic = { ver, assets }: stdenv.mkDerivation rec {
    pname = "d${toString ver}x-rebirth-with-assets";
    inherit (dxx-rebirth) version;

    nativeBuildInputs = [ makeWrapper ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      makeWrapper ${dxx-rebirth}/bin/d${toString ver}x-rebirth $out/bin/descent${toString ver} \
        --add-flags "-hogdir ${assets}/share/descent${toString ver}-assets"

      runHook postInstall
    '';

    meta = with stdenv.lib; {
      description = "Descent ${toString ver} using the DXX-Rebirth project engine and game assets from GOG";
      license = with licenses; [ free unfree ];
      inherit (dxx-rebirth.meta) homepage maintainers platforms;
      hydraPlatforms = [];
    };
  };

in {
  d1x-rebirth-with-assets = generic {
    ver = 1;
    assets = descent1-assets;
  };

  d2x-rebirth-with-assets = generic {
    ver = 2;
    assets = descent2-assets;
  };
}
