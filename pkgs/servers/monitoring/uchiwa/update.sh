#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl.bin git.out nix jq.out nodePackages.bower2nix

set -euo pipefail
IFS=$'\n\t'

# set -x

REPO=sensu/uchiwa
SHA="1111111111111111111111111111111111111111111111111111"

write_src() {
  cat <<_EOF > src.nix
{
  version = "${VERSION}";
  sha256  = "${SHA}";
}
_EOF
}

LATEST_VERSION=$(curl https://api.github.com/repos/${REPO}/tags -s | jq '.[0]' -r | jq .name -r)
echo "Latest version: ${LATEST_VERSION}"

VERSION=${1:-${LATEST_VERSION}}
echo "Updating to: ${VERSION}"

TOP=$(git rev-parse --show-toplevel)

cd $(dirname $0)

write_src
SHA=$(cd "$TOP" && nix-prefetch-url -A uchiwa.src)
write_src

curl https://raw.githubusercontent.com/${REPO}/${VERSION}/bower.json -s > bower.json
rm -f bower-packages.nix
bower2nix bower.json bower-packages.nix
