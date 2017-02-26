{ stdenv, fetchFromGitHub, nix }:

stdenv.mkDerivation rec {
  name = "nix-upgrade-scripts-${version}";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner  = "peterhoeg";
    repo   = "nix-upgrade-scripts";
    rev    = "v${version}";
    sha256 = "0kqy6pzw7gpiag2i3ggh1jqiyc7v9anrqg52bllhhj1fcfvfgra3";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r lib $out/
    for f in $out/bin/* ; do
      substitute $f $out/bin/$(dirname $f) \
        --replace '/usr/bin/env nix-shell' ${nix}/bin/nix-shell
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
