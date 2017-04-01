{ stdenv, fetchFromGitHub, nodejs, writeScript }:

let
  version = "1.1.0";

  src = fetchFromGitHub {
    owner  = "asamuzaK";
    repo   = "withExEditorHost";
    rev    = "v${version}";
    sha256 = "07shvq3yafjgdvv96igq5f0qrgbgl5146g5c4fjixzjzqs8czpmm";
  };

  run = writeScript "withexeditiorhost.sh" ''
    ${stdenv.shell} -e
    ${nodejs}/bin/node ${src}/index.js
  '';

in stdenv.mkDerivation rec {
  name = "withexeditorhost-${version}";

  inherit src;

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm755 ${run} $out/bin/withexeditorhost.sh
  '';

  meta = with stdenv.lib; {
    description = "Native messaging host for withExEditor";
    homepage    = https://github.com/asamuzaK/withExEditorHost;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
