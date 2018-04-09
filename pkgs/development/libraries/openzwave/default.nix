{ stdenv, fetchFromGitHub
, doxygen, libxml2, git, which, pkgconfig, graphviz-nox, fontconfig
, udev }:

let
  version = "2018-04-04";

in stdenv.mkDerivation rec {
  name = "openzwave-${version}";

  src = fetchFromGitHub {
    owner = "OpenZWave";
    repo = "open-zwave";
    rev = "ab5fe966fee882bb9e8d78a91db892a60a1863d9";
    sha256 = "0yby8ygzjn5zp5vhysxaadbzysqanwd2zakz379299qs454pr2h9";
  };

  nativeBuildInputs = [ doxygen libxml2 git which pkgconfig graphviz-nox fontconfig ];
  buildInputs = [ udev ];

  installFlags = [
    "PREFIX="
    "pkgconfigdir=lib/pkgconfig"
    "sysconfigdir=etc/openzwave"
  ];

  preInstall = ''
    installFlagsArray+=("DESTDIR=$out")
  '';

  FONTCONFIG_FILE="${fontconfig.out}/etc/fonts/fonts.conf";
  FONTCONFIG_PATH="${fontconfig.out}/etc/fonts/";

  postPatch = ''
    sed -i "s#/etc/openzwave/#$out/etc/openzwave/#" cpp/src/Options.cpp
  '';

  fixupPhase = ''
    sed -i "s#dir=#dir=$out#" $out/lib/pkgconfig/libopenzwave.pc
    sed -i "s#pcfile=#pcfile=$out/#" $out/bin/ozw_config
  '';

  meta = with stdenv.lib; {
    description = "C++ library to control Z-Wave Networks via a USB Z-Wave Controller";
    homepage = http://www.openzwave.net/;
    license = licenses.gpl3;
    maintainers = [ maintainers.etu ];
    platforms = platforms.linux;
  };
}
