{ stdenv, fetchurl, pkgconfig, libusb1 }:

let
   version = "2.4.0";

in stdenv.mkDerivation rec {
  name = "usb-modeswitch-${version}";

  src = fetchurl {
    url = "http://www.draisberghof.de/usb_modeswitch/${name}.tar.bz2";
    sha256 = "04p288pr477jqlj1b9dagwsg5n6z6iyi7db94c7kg3nz22zk5p0p";
  };

  # make clean: we always build from source. It should be necessary on x86_64 only
  preConfigure = ''
    find -type f | xargs sed 's@/bin/rm@rm@g' -i
    make clean
    mkdir -p $out/{etc,lib/udev,share/man/man1}
    makeFlags="DESTDIR=$out PREFIX=$out"
  '';

  buildInputs = [ pkgconfig libusb1 ];

  meta = with stdenv.lib; {
    description = "A mode switching tool for controlling 'multi-mode' USB devices";
    license = licenses.gpl2;
    maintainers = with maintainers; [ marcweber peterhoeg ];
    platforms = platforms.linux;
  };
}
