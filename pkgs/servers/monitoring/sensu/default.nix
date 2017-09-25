{ lib, bundlerApp }:

bundlerApp rec {
  pname = "sensu";
  gemdir = ./.;

  exes = [ "sensu-*" ];

  meta = with lib; {
    description = "A monitoring framework that aims to be simple, malleable, and scalable";
    homepage    = https://sensuapp.org/;
    license     = licenses.mit;
    maintainers = with maintainers; [ theuni peterhoeg ];
    platforms   = platforms.unix;
  };
}
