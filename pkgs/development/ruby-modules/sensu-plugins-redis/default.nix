{ lib, bundlerApp, ruby }:

bundlerApp rec {
  pname = "sensu-plugins-redis";
  gemdir = ./.;
  exes = [ "check-*" "metrics-*" "handler-*" "mutator-*" ];

  meta = with lib; {
    description = "Sensu plugin: sensu-plugins-redis";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
    priority = 10;
  };
}
