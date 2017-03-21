{
  kdeDerivation, kdeWrapper, fetchFromGitHub, lib,
  extra-cmake-modules, kdoctools,
  audiocd-kio, kcmutils, kconfig, kinit, knotifications, knotifyconfig, kdelibs4support, libkcompactdisc,
  cdparanoia, flac, libdiscid, taglib
}:

let
  pname = "kaudiocreator";
  version = "3.9.99";
  unwrapped = kdeDerivation rec {
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "KDE";
      repo = "kaudiocreator";
      rev = "0514d9e784ce7a78bc16e4122ac86a89fc48f8c1";
      sha256 = "1xsp38h4bf0i9lvk0vsijx6gc712x5dg664mfawmx3ax90cx69ls";
    };

    buildInputs = [ cdparanoia flac libdiscid taglib ];
    nativeBuildInputs = [ extra-cmake-modules kdoctools ];
    propagatedBuildInputs = [ audiocd-kio kcmutils kconfig kinit knotifyconfig kdelibs4support libkcompactdisc ];

    meta = with lib; {
      license = licenses.gpl2;
      maintainers = with maintainers; [ peterhoeg ];
    };
  };

in kdeWrapper {
  inherit unwrapped;
  targets = [ "bin/kaudiocreator" ];
}
