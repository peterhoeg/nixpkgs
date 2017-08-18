{
  mkDerivation, fetchgit, lib,
  autoreconfHook, kdoctools, wrapGAppsHook,
  kconfig, kcrash, kinit
}:

let
  pname = "xsettings-kde";
  version = "20160505";

in mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchgit {
    url    = "git://anongit.kde.org/${pname}.git";
    rev    = "5bf1e8dc3c35e8d9eb19b91c743aa6507808e787";
    sha256 = "0d19607r6j4cpnix8ryrmlfrj71cdqpn6bxlgn2vwmcvli4j9nv5";
  };

  meta = with lib; {
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
  nativeBuildInputs = [ autoreconfHook kdoctools wrapGAppsHook ];
  propagatedBuildInputs = [ kconfig kcrash kinit ];
}
