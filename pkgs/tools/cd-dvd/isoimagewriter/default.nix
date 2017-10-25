{ mkDerivation, fetchurl, lib
, extra-cmake-modules, kdoctools
, kauth, kiconthemes, kwidgetsaddons
, gpgme, qgpgme }:

let
  pname = "isoimagewriter";
  version = "0.2";

in mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url    = "mirror://kde/unstable/${pname}/${version}/${name}.tar.xz";
    sha256 = "0475r2qq8jzpd9wb4fx43n2plbnwq4mfbfhcaq5h8md3nm3h5gva";
  };

  nativeBuildInputs = [ extra-cmake-modules kdoctools ];

  buildInputs = [ gpgme qgpgme ];

  propagatedBuildInputs = [ kauth kiconthemes kwidgetsaddons ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A KDE CD/DVD Burner";
    license     = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
