#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.bower2nix

set -euo pipefail
IFS=$'\n\t'

VERSION=0.21.0

t=$(mktemp)

curl https://raw.githubusercontent.com/sensu/uchiwa/${VERSION}/bower.json > $t
bower2nix $t > bower-packages.nix
