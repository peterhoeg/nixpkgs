{ lib, stdenv, fetchurl, cmake, taglib, zlib }:

stdenv.mkDerivation rec {
  pname = "taglib-extras";
  version = "1.0.1";

  src = fetchurl {
    url = "https://download.kde.org/stable/taglib-extras/1.0.1/src/${pname}-${version}.tar.gz";
    sha256 = "sha256-/lRrSzFfMifJdf7Y6p38DlT8aZf9u6Kp2nvrpHkiljI=";
  };

  buildInputs = [ taglib zlib ];

  nativeBuildInputs = [ cmake ];

  # Workaround for upstream bug https://bugs.kde.org/show_bug.cgi?id=357181
  preConfigure = ''
    sed -i -e 's/STRLESS/VERSION_LESS/g' cmake/modules/FindTaglib.cmake
  '';

  meta = with lib; {
    description = "Additional taglib plugins";
    license = licenses.lgpl2;
    platforms = platforms.unix;
  };
}
