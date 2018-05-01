{ stdenv, lib, fetchurl, cmake, pkgconfig, extra-cmake-modules
, qtbase, qtx11extras
, pcre, phonon, libvlc
}:

with lib;

let
  v = "0.10.1";
  pname = "phonon-backend-vlc";

in stdenv.mkDerivation rec {
  name = "${pname}-${v}";

  src = fetchurl {
    url = "mirror://kde/stable/phonon/${pname}/${v}/${pname}-${v}.tar.xz";
    sha256 = "0b87mzkw9fdkrwgnh1kw5i5wnrd05rl42hynlykb7cfymsk6v5h9";
  };

  buildInputs = [
    pcre phonon libvlc
    qtbase qtx11extras
  ];

  nativeBuildInputs = [ cmake pkgconfig extra-cmake-modules ];

  cmakeFlags = [
    "-DPHONON_BUILD_PHONON4QT5=ON"
  ];

  meta = with stdenv.lib; {
    description = "GStreamer backend for Phonon";
    homepage = https://phonon.kde.org/;
    platforms = platforms.linux;
  };
}
