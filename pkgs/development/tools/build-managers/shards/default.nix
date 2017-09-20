{ stdenv, fetchFromGitHub, crystal, libyaml, which }:

stdenv.mkDerivation rec {
  name = "shards-${version}";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner  = "crystal-lang";
    repo   = "shards";
    rev    = "v${version}";
    sha256 = "09rama4xpm9xvs63nqxlhl84gppm6i750rq4m4khp208ln4jmphd";
  };

  buildInputs = [ crystal libyaml ];

  nativeBuildInputs = [ which ];

  buildFlags = [ "CRFLAGS=" "release" ];

  installPhase = ''
    install -Dm755 bin/shards $out/bin/shards
  '';

  meta = with stdenv.lib; {
    description = "Dependency manager for the Crystal language";
    inherit (crystal.meta) homepage license maintainers platforms;
  };
}
