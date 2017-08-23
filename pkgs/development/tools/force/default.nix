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

  preBuild = ''
    export GOPATH=$GOPATH:$NIX_BUILD_TOP/go/src/${goPackagePath}/Godeps/_workspace:${src}/Godeps/_workspace/src
  '';

  meta = with stdenv.lib; {
    description = "SalesForce Force CLI tools";
    homepage    = https://www.salesforce.com;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
