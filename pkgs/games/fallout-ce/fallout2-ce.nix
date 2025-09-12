{
  lib,
  callPackage,
  callPackages,
  fetchFromGitHub,
  fetchpatch2,
  fetchurl,
  zlib,
  assets ? [ ], # see build.nix for details
  withGogAssets ? false,
}:

let
  version = "1.3.0";

in
callPackage ./build.nix {
  pname = "fallout2-ce";
  gameVersion = 2;
  inherit version;

  assets =
    assets
    ++ lib.optionals withGogAssets [ (callPackages ./assets.nix { }).fallout2-assets-gog ];

  src = fetchFromGitHub {
    owner = "alexbatalov";
    repo = "fallout2-ce";
    rev = "v${version}";
    hash = "sha256-r1pnmyuo3uw2R0x9vGScSHIVNA6t+txxABzgHkUEY5U=";
  };

  patches = [
    # Fix case-sensitive filesystems issue when save/load games
    (fetchpatch2 {
      url = "https://github.com/alexbatalov/fallout2-ce/commit/d843a662b3ceaf01ac363e9abb4bfceb8b805c36.patch";
      sha256 = "sha256-r4sfl1JolWRNd2xcf4BMCxZw3tbN21UJW4TdyIbQzgs=";
    })
  ];

  buildInputs = [ zlib ];

  icon = fetchurl {
    url = "https://github.com/alexbatalov/fallout2-ce/blob/f411d75643211dce56772ff54c7a21494b6a1d9f/os/ios/AppIcon.xcassets/AppIcon.appiconset/AppIcon.png?raw=true";
    hash = "sha256-i3GuH4537ehujtcJpRev0Dtbmb1245PGd95DwXQl0CI=";
    name = "fallout2-ce.png";
  };

  meta.homepage = "https://github.com/alexbatalov/fallout2-ce";
}
