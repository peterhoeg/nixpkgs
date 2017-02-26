{ stdenv, fetchFromGitHub, nix }:

stdenv.mkDerivation rec {
  name = "nix-upgrade-scripts-${version}";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner  = "peterhoeg";
    repo   = "nix-upgrade-scripts";
    rev    = "v${version}";
    sha256 = "19ggravv56vy425vdqy5qhngsbwngfhkwwy6gbcjh02ydcza1agv";
  };

  installPhase = ''
    mkdir -p $out
    cp -r bin lib $out/
    for f in $out/bin/* ; do
      substituteInPlace $f --replace '/usr/bin/env nix-shell' ${nix}/bin/nix-shell
    done
    chmod +x $out/bin/*
  '';

  meta = with stdenv.lib; {
    description = "Scripts for making package upgrades easier";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
