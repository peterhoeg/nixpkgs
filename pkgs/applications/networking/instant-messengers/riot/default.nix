{ recurseIntoAttrs, callPackage, nodejs }:

let
  self = recurseIntoAttrs (
    callPackage ../../../../top-level/node-packages.nix {
      inherit nodejs self;
      generated = callPackage ./node-packages.nix { inherit self; };
      overrides = {
        "riot" = { passthru.nodePackages = self; };
      };
    });
in self.riot
