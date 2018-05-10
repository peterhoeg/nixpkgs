{ stdenv, lib, buildGoPackage, fetchFromGitHub, makeWrapper
, nodejs }:

let
  generic = product: buildGoPackage rec {
    name = "sensu-${version}";
    version = "2.0.0-beta.1-2";

    goPackagePath = "github.com/sensu/sensu-go";

    src = fetchFromGitHub {
      owner  = "sensu";
      repo   = "sensu-go";
      rev    = "${version}";
      sha256 = "1c1kdrbq1m06as5i9jhzr3vxavi82w7jgph7glaarf5k1znrp8p5";
    };

    # goDeps = ./deps.nix;

    buildInputs = [ makeWrapper ] ++ lib.optional (product == "backend") nodejs;

    makeFlags = [
      "deps"
      "build_${product}"
    ];

    preBuild = ''
      export PATH=$GOPATH/bin:$PATH
    '';

    meta = with lib; {
      description = "A monitoring framework that aims to be simple, malleable, and scalable";
      homepage    = https://sensuapp.org/;
      license     = licenses.mit;
      maintainers = with maintainers; [ peterhoeg ];
      platforms   = platforms.unix;
    };
  };

in {
  sensu-agent   = generic "agent";
  sensu-backend = {}; #generic "backend";
  sensu-cli     = generic "cli";
}
