{ stdenv, fetchFromGitHub, bundlerEnv, bundler, ruby }:

let
  version = "20171201";

  rubyEnv = bundlerEnv rec {
    name = "huginn-env-${version}";

    inherit ruby;
    gemdir = ./.;
  };

in stdenv.mkDerivation rec {
  name = "huginn-${version}";

  src = fetchFromGitHub {
    owner  = "huginn";
    repo   = "huginn";
    rev    = "1e286bce0f1ee3cbfb77dbced0799ebc5f0924ef";
    sha256 = "14gfyjsgh7h9hp8841x47iyv6y1wc5af41h8gbg4rkxx1xlia494";
  };

  buildInputs = [
    rubyEnv ruby bundler
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/huginn
    cp -r * $out/share/huginn
    ln -s $out/share/huginn/bin $out/bin

    runHook postInstall
  '';

  passthru = {
    inherit rubyEnv;
    inherit ruby;
  };

  meta = with stdenv.lib; {
    description = "Create agents that monitor and act on your behalf. Your agents are standing by! ";
    homepage    = https://github.com/huginn/huginn;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
