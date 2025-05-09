{
  lib,
  callPackage,
  callPackages,
  fetchFromGitHub,
  fetchurl,
  assets ? [ ], # see build.nix for details
  withGogAssets ? false,
}:

let
  version = "1.0.0.20231031";

in
callPackage ./build.nix {
  pname = "fallout-ce";
  inherit version;
  gameVersion = 1;

  assets =
    assets
    ++ lib.optionals withGogAssets [ (callPackages ./assets.nix { }).fallout1-assets-gog ];

  src = fetchFromGitHub {
    owner = "alexbatalov";
    repo = "fallout1-ce";
    rev = "f33143d0db9066d4c654464f66aba58871e4c81e";
    hash = "sha256-5gRuUrO5/5pKor3fuKY/cXMkkbPvkhICrR2fPKRTaTU=";
  };

  icon = fetchurl {
    url = "https://github.com/alexbatalov/fallout1-ce/blob/f33143d0db9066d4c654464f66aba58871e4c81e/os/ios/AppIcon.xcassets/AppIcon.appiconset/AppIcon.png?raw=true";
    hash = "sha256-pKDDD8TdRWma1BcHx1KNg12EoK2sfc3SKE7arMcd8OQ=";
    name = "fallout-ce.png";
  };

  meta = {
    homepage = "https://github.com/alexbatalov/fallout1-ce";
    broken = true; # segfault on start
  };
}
