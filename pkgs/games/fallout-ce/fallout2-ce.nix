{ lib
, callPackage
, callPackages
, fetchFromGitHub
, fetchurl
, zlib
, assets ? [ ] # see build.nix for details
, withGogAssets ? false
}:

let
  version = "1.3.0";

in
callPackage ./build.nix {
  pname = "fallout2-ce";
  gameVersion = 2;
  inherit version;

  assets = assets ++ lib.optionals withGogAssets [ (callPackages ./assets.nix { }).fallout2-assets-gog ];

  src = fetchFromGitHub {
    owner = "alexbatalov";
    repo = "fallout2-ce";
    rev = "v${version}";
    hash = "sha256-r1pnmyuo3uw2R0x9vGScSHIVNA6t+txxABzgHkUEY5U=";
  };

  buildInputs = [ zlib ];

  icon = fetchurl {
    url = "https://github.com/alexbatalov/fallout2-ce/blob/f411d75643211dce56772ff54c7a21494b6a1d9f/os/ios/AppIcon.xcassets/AppIcon.appiconset/AppIcon.png?raw=true";
    hash = "sha256-i3GuH4537ehujtcJpRev0Dtbmb1245PGd95DwXQl0CI=";
    name = "fallout2-ce.png";
  };

  meta.homepage = "https://github.com/alexbatalov/fallout2-ce";
}
