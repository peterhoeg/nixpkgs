import ./make-test.nix ({ pkgs, ... }:

let
  host = "zm";
  port = 80;

in {
  name = "zoneminder";
  meta = with pkgs.stdenv.lib; {
    maintainers = with maintainers; [ peterhoeg ];
  };

  nodes = {
    zm = { pkgs, ... }:
    {
      networking.hosts = {
        # "127.0.0.1" = [ "localhost" host ];
      };

      services.mysql = {
        package = pkgs.mariadb;
      };

      services.zoneminder = {
        inherit port;
        enable = true;
        openFirewall = true;
        database.createLocally = true;
      };

      time.timeZone = "UTC";
    };
  };

  testScript = ''
    startAll;
    $zm->waitForUnit("zoneminder.service");

    $zm->succeed("curl --fail http://${host}/");
  '';
})
