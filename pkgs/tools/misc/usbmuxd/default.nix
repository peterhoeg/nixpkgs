{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, libplist, libusb1, libimobiledevice }:

stdenv.mkDerivation rec {
  name = "usbmuxd-${version}";
  version = "1.1.0.20180515";

  src = fetchFromGitHub {
    owner  = "libimobiledevice";
    repo   = "usbmuxd";
    rev    = "08d9ec01cf59c7bb3febe3c4600e9efeb81901e3";
    sha256 = "0432blqi2fapdj91hk4ppzmqy9dxymc1msi159h82gf7qqbngcm2";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ libusb1 libplist libimobiledevice ];

  enableParallelBuilding = true;

  configureFlags = [
    "--with-udevrulesdir=$(out)/lib/udev/rules.d"
    "--with-systemdsystemunitdir=$(out)/lib/systemd/system"
  ];

  meta = with stdenv.lib; {
    description = "USB Multiplex Daemon (for talking to iPhone or iPod)";
    homepage = http://marcansoft.com/blog/iphonelinux/usbmuxd/;
    longDescription = ''
      usbmuxd: USB Multiplex Daemon. This bit of software is in charge of
      talking to your iPhone or iPod Touch over USB and coordinating access to
      its services by other applications.'';
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
