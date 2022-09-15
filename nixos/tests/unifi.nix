# Test UniFi controller

{ system ? builtins.currentSystem
, config ? { allowUnfree = true; }
, pkgs ? import ../.. { inherit system config; }
}:

with import ../lib/testing-python.nix { inherit system pkgs; };
with pkgs.lib;

let
  httpPort = 8080;
  httpsPort = 18443;

  makeAppTest = unifi: makeTest {
    name = "unifi-controller-${unifi.version}";
    meta = with pkgs.lib.maintainers; {
      maintainers = [ patryk27 zhaofengli ];
    };

    nodes.server = {
      services.unifi = {
        enable = true;
        unifiPackage = unifi;
        openFirewall = false;
        inherit httpPort httpsPort;
      };
    };

    testScript = ''
      server.wait_for_unit("unifi.service")
      server.wait_until_succeeds("curl -Lk https://localhost:${toString httpsPort} >&2", timeout=300)
    '';
  };

in
with pkgs; {
  unifiLTS = makeAppTest unifiLTS;
  unifi5 = makeAppTest unifi5;
  unifi6 = makeAppTest unifi6;
  unifi7 = makeAppTest unifi7;
}
