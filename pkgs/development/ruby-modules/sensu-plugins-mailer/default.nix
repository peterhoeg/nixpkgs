{ lib, bundlerApp, ruby }:

bundlerApp rec {
  pname = "sensu-plugins-mailer";
  gemdir = ./.;
  exes = [ "check-*" "metrics-*" "handler-*" "mutator-*" ];

  meta = with lib; {
    description = "Sensu plugin: sensu-plugins-mailer";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
    priority = 10;
  };
}
