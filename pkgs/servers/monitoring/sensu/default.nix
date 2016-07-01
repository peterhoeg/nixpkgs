{ stdenv, bundlerEnv, ruby }:

bundlerEnv rec {
  name = "sensu-${version}";
  version = (import gemset).sensu.version;

  inherit ruby;
  gemfile  = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset   = ./gemset.nix;

  meta = with stdenv.lib; {
    description = "A monitoring framework that aims to be simple, malleable, and scalable";
    homepage    = http://sensuapp.org/;
    license     = licenses.mit;
    maintainers = with maintainers; [ theuni peterhoeg ];
    platforms   = platforms.unix;
  };
}
