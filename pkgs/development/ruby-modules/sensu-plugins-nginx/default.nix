{ lib, bundlerApp, ruby }:

bundlerApp rec {
  pname = "sensu-plugins-nginx";
  gemdir = ./.;
  exes = [ "check-*" "metrics-*" "handler-*" "mutator-*" ];

  meta = with lib; {
    description = "Sensu plugin: sensu-plugins-nginx";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
    priority = 10;
  };
}
