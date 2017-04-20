#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.node2nix

# node2nix -6 -c nodepkgs.nix -e ../../node-packages/node-env.nix
node2nix -6 -c nodepkgs.nix -e ./node-env.nix
