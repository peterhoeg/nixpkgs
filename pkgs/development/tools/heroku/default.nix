{ stdenv, lib, fetchurl, makeWrapper, buildGoPackage, fetchFromGitHub
, nodejs-6_x, postgresql, ruby }:

with stdenv.lib;

let
  src = fetchFromGitHub {
    owner  = "heroku";
    repo   = "cli";
    rev    = "v${version}";
    sha256 = "11jccham1vkmh5284l6i30na4a4y7b1jhi2ci2z2wwx8m3gkypq9";
  };

  cli = buildGoPackage rec {
    name = "cli-${version}";
    version = "5.6.14";

    goPackagePath = "github.com/heroku/cli";

    inherit src;
  };

in stdenv.mkDerivation rec {
  name = "heroku-${version}";
  version = "3.43.16";

  inherit src;

  meta = {
    homepage = "https://toolbelt.heroku.com";
    description = "Everything you need to get started using Heroku";
    maintainers = with maintainers; [ aflatter mirdhyn peterhoeg ];
    license = licenses.mit;
    platforms = with platforms; unix;
  };

  binPath = lib.makeBinPath [ postgresql ruby ];

  buildInputs = [ makeWrapper ];

  doUnpack = false;

  installPhase = ''
    mkdir -p $out

    tar xzf $src -C $out --strip-components=1
    install -Dm755 ${cli}/bin/cli $out/share/heroku/cli/bin/heroku

    wrapProgram $out/bin/heroku \
      --set HEROKU_NODE_PATH ${nodejs-6_x}/bin/node \
      --set XDG_DATA_HOME    $out/share \
      --set XDG_DATA_DIRS    $out/share \
      --prefix PATH : ${binPath}
  '';
}
