import ./make-test.nix ({ pkgs, ... } : {
  name = "caddy";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ peterhoeg ];
  };

  nodes = {
    machine = { config, pkgs, ... }: {
      services.caddy = {
        enable = true;
        agree = true;
      };
    };
  };

  testScript = ''
    startAll;
    $machine->waitForUnit("caddy.service");
    $machine->succeed("curl http://localhost:80/");
    $machine->succeed("curl https://localhost:443/");
  '';
})
