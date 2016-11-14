{ stdenv, fetchurl, pkgconfig, libusb1, tcl, usb-modeswitch }:

let
   version = "20160803";

in stdenv.mkDerivation rec {
  name = "usb-modeswitch-data-${version}";

  src = fetchurl {
     url = "http://www.draisberghof.de/usb_modeswitch/${name}.tar.bz2";
     sha256 = "1zjnlxhnlra6z3h38q9j7yzzf22h4zwnpq8afhvqajz3qrvs5x43";
   };

  # make clean: we always build from source. It should be necessary on x86_64 only
  prePatch = ''
    sed -i 's@usb_modeswitch@${usb-modeswitch}/bin/usb_modeswitch@g' 40-usb_modeswitch.rules
    sed -i "1 i\DESTDIR=$out" Makefile
  '';

  # we add tcl here so we can patch in support for new devices by dropping config into
  # the usb_modeswitch.d directory
  buildInputs = [ pkgconfig libusb1 tcl usb-modeswitch ];

  meta = with stdenv.lib; {
    description = "Device database and the rules file for 'multi-mode' USB devices";
    inherit (usb-modeswitch.meta) license maintainers platforms;
  };
}
