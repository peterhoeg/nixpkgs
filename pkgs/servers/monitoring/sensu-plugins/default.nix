{ stdenv, bundlerEnv, ruby, sensu }:

bundlerEnv rec {
  name = "sensu-plugins-${version}";
  version = "1.4.4";

  inherit ruby;
  gemfile  = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset   = ./gemset.nix;

  meta = with stdenv.lib; {
    description = "Plugins for the sensu monitoring framework";
    homepage    = http://sensuapp.org/;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
