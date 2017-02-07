#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gzip gnugrep coreutils

set -euo pipefail
IFS=$'\n\t'

URL=http://repository.spotify.com/dists/stable/non-free/binary-amd64/Packages.gz

curl --silent $URL | gunzip | grep Version | sort -nu | tail -n1 | cut -f3 -d ':'
