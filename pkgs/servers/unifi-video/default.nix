{ stdenv, fetchurl, dpkg }:

assert stdenv.isx86_64;

stdenv.mkDerivation rec {
  name = "unifi-video-${version}";
  version = "3.1.2";

  src = fetchurl {
    url = "https://dl.ubnt.com/firmwares/unifi-video/${version}/unifi-video_${version}-Debian7_amd64.deb";
    sha256 = "09m92apjjfsmjcj82l776hrplfzbc0lnpmfxndbbxsnbagi3zmb8";
  };

  buildInputs = [ dpkg ];

  doConfigure = false;

  buildCommand = ''
    mkdir -p $out
    dpkg --extract $src $out
  '';

  meta = with stdenv.lib; {
    homepage = http://www.ubnt.com/;
    description = "Controller for Ubiquiti Video cameras.";
    license = licenses.unfree;
    platforms = platforms.unix;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
