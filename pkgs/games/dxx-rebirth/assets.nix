{ stdenv, fetchurl, requireFile, gogUnpackHook }:

let
  generic = { ver, name, version, sha256, musicSha256 }: stdenv.mkDerivation (let
    music = fetchurl {
      url = "https://www.dxx-rebirth.com/download/dxx/res/d${toString ver}xr-sc55-music.dxa";
      sha256 = musicSha256;
    };
  in rec {
    pname = "descent${toString ver}-assets";
    inherit version;

    src = requireFile {
      inherit name sha256;
      message = ''
        While the Descent ${toString ver} game engine is free, the game assets are not.

        Please purchase the game on gog.com and download the Windows installer.

        Once you have downloaded the file, please use the following command and re-run the
        installation:

        nix-prefetch-url file://\$PWD/${name}
      '';
    };

    nativeBuildInputs = [ gogUnpackHook ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/{${pname},doc/${pname}/examples}

      pushd ./app
      find . -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;

      rm -rf dosbox
      mv dosbox*.conf $out/share/doc/${pname}/examples
      mv *.txt *.pdf  $out/share/doc/${pname}
      cp -r * $out/share/${pname}
      popd

      ln -s ${music} $out/share/${pname}/${music.name}

      runHook postInstall
    '';

    meta = with stdenv.lib; {
      description = "Descent ${toString ver} game assets from GOG";
      homepage = "https://www.gog.com";
      license = licenses.unfree;
      maintainers = with maintainers; [ peterhoeg ];
      hydraPlatforms = [];
    };
  });

in {
  descent1-assets = generic rec {
    ver = 1;
    name = "setup_descent_${version}.exe";
    version = "2.1.0.8";
    sha256 = "0iih1mfai9r0mnks1yfln1c9477xp05rij48p0zfq480dr1kwb8d";
    musicSha256 = "0bwncxw9slj5wwim4aiswwbkql6rvycr8v6509279hprqnfpnzxj";
  };

  descent2-assets = generic rec {
    ver = 2;
    name = "setup_descent2_${version}.exe";
    version = "2.1.0.10";
    sha256 = "0l4pgjzf6svjvw03m8s1n0xrscc6f61rxm1a8hybz97qfiaxk1z7";
    musicSha256 = "05mz77vml396mff43dbs50524rlm4fyds6widypagfbh5hc55qdc";
  };
}
