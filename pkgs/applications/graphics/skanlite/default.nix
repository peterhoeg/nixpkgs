{
  mkDerivation, fetchurl, lib,
  extra-cmake-modules, kdoctools, wrapGAppsHook,
  kconfig, kcrash, kinit, kdeApplications
}:

let
  pname = "skanlite";
  mainVersion = "2.0";

in mkDerivation rec {
  name = "${pname}-${mainVersion}.1";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${mainVersion}/${name}.tar.xz";
    sha256 = "0dh2v8029gkhcf3pndcxz1zk2jgpihgd30lmplgirilxdq9l2i9v";
  };

  meta = with lib; {
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools wrapGAppsHook ];
  propagatedBuildInputs = [ kconfig kcrash kinit kdeApplications.libksane ];
}
