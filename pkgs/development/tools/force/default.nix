{ stdenv, go, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "force-cli-${version}";
  version = "0.22.76";

  src = fetchFromGitHub {
    owner  = "heroku";
    repo   = "force";
    rev    = "v${version}";
    sha256 = "0ff61yd4f8dqkbi2p3rz9ibig638z0qzi452shyad44hyllpb09v";
  };

  goPackagePath = "github.com/heroku/force";

  godeps = ./deps.nix;

  preBuild = ''
    ls -la
    mkdir -p go/src
    cp -r $src/Godeps/_workspace/src/* go/src/
  '';

  meta = with stdenv.lib; {
    description = "SalesForce Force CLI tools";
    homepage    = https://www.salesforce.com;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
