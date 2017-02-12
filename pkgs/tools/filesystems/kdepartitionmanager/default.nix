{
  kdeDerivation, kdeWrapper, fetchFromGitHub, lib,
  ecm, kdoctools,
  kconfig, kinit,
  kpmcore, parted
}:

let
  pname = "kdepartitionmanager";
  version = "3.0.1";
  unwrapped = kdeDerivation rec {
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "KDE";
      repo = "partitionmanager";
      rev = "v${version}";
      sha256 = "1v2mpf47ljghyf701ynrzmr5j4vvwby8lvm6a1slwp2s9gxl5m2p";
    };

    meta = with lib; {
      license = licenses.gpl2;
      maintainers = with maintainers; [ peterhoeg ];
    };
    buildInputs = [ parted ];
    nativeBuildInputs = [ ecm kdoctools ];
    propagatedBuildInputs = [ kconfig kinit kpmcore ];

    preConfigure = ''
      echo ${kpmcore}/lib/cmake/KPMcore
      exit 1
    '';

    cmakeFlags = [
    ];
  };

in kdeWrapper {
  inherit unwrapped;
  targets = [ "bin/kpm" ];
}
