{ stdenv, lib, fetchFromGitHub, nodejs }:

with lib;

let
  nodePackages = import ./nodepkgs.nix {
    inherit pkgs;
    inherit (stdenv) system;
  };

in stdenv.mkDerivation rec {
  name = "matrix-appservice-slack-${version}";
  version = "2016-12-23";

  src = fetchFromGitHub {
    owner  = "matrix-org";
    repo   = "matrix-appservice-slack";
    rev    = "f4bb800e0b112bc954d37ab8e76f7bd1540e3fc0";
    sha256 = "0p3777mcspqpfb8jj8xw36m9imccxyjvd2bzpnffxmdahp2nh2wn";
  };

  buildInputs = [ nodejs ] ++ (with nodePackages; [
    bluebird
  ]);

  configurePhase = ''
    mkdir -p node_modules/.bin
    ${concatStrings (map (dep: ''
      test -d ${dep}/bin && (for b in $(ls ${dep}/bin); do
        ln -sv -t node_modules/.bin ${dep}/bin/$b
      done)
    '') buildInputs)}
  '';

  buildPhase = ''
    node make all
  '';

  installPhase = ''
    dir=$out/lib/node_modules/matrix-appservice-slack
    mkdir -p $dir $dir/.bin

    cp -r app.js external lib $dir

    cat <<EOF >$dir/.bin/matrix-appservice-slack
    ${stdenv.shell} -e
    exec ${nodejs}/bin/node $dir/app.js \$@
    EOF

    ln -s $dir/.bin $out/bin
    chmod 755 $out/bin/*
  '';

  meta = with lib; {
    homepage    = http://matrix.org;
    description = "A Matrix <--> Slack bridge";
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
    license     = licenses.apache;
  };
}
