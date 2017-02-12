{
  kdeDerivation, kdeWrapper, fetchFromGitHub, lib,
  ecm, kdoctools,
  kconfig, kinit,
  libatasmart, utillinux, parted
}:

let
  pname = "kpmcore";
  version = "3.0.3";
  unwrapped = kdeDerivation rec {
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "KDE";
      repo = "kpmcore";
      rev = "v${version}";
      sha256 = "1pzjizcrdqicx1cmkp7kpa3gg1g9cp6k6g7ivlc6kiv8kvbfrx1w";
    };

    outputs = [ "bin" "lib" "out" "dev" ];

    meta = with lib; {
      license = licenses.gpl2;
      maintainers = with maintainers; [ peterhoeg ];
    };
    buildInputs = [ libatasmart utillinux parted ];
    nativeBuildInputs = [ ecm kdoctools ];
    propagatedBuildInputs = [ kconfig kinit ];
  };

in kdeWrapper {
  inherit unwrapped;
  targets = [ ];
}
