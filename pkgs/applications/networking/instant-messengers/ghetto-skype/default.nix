{ stdenv, fetchFromGitHub, nix, electron, nodejs, pkgs }:

let
  pname = "ghetto-skype";
  version = "1.5.0";

  nodePackages = import ./composition.nix {
    inherit pkgs nodejs;
  };

in stdenv.mkDerivation rec {
  name = "ghetto-skype-${version}";

  src = fetchFromGitHub {
    owner  = "stanfieldr";
    repo   = pname;
    rev    = "v${version}";
    sha256 = "0hw2bihdcbc4lyrrfkljb8pvmk8qin0pla1836hmv87rxhvg1a2i";
  };

  buildInputs = [ nix ];

  buildPhase = ''
    nix-build -A package
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/node_modules/${pname}
    cp -r src/* $out/lib/node_modules/${pname}
    cat <<_EOF > $out/bin/${pname}
    #! ${stdenv.shell} -eu
    ${electron}/bin/electron $out/lib/node_modules/${pname}/main.js
    _EOF
    chmod 755 $out/bin/${pname}
  '';
}
