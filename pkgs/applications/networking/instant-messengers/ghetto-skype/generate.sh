#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.node2nix

set -euo pipefail

node2nix -6 --flatten \
  -i package.json \
  -c composition.nix \
  -o node-packages.nix \
  -e ../../../../development/node-packages/node-env.nix
