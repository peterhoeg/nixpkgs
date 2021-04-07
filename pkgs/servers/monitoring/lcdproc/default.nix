{ stdenv
, fetchFromGitHub
, autoreconfHook
, makeWrapper
, pkg-config
, doxygen
, freetype
, libX11
, libftdi
, libusb-compat-0_1
, libusb1
, ncurses
, perl
}:

stdenv.mkDerivation rec {
  pname = "lcdproc";
  version = "unstable-2021-02-10";

  src = fetchFromGitHub {
    owner = "lcdproc";
    repo = "lcdproc";
    rev = "5c21e8c75fbab53574275c8007f5af746e333144";
    sha256 = "sha256-vZA9fCuwF8PvceJDkOfOoYPGqLPjOIGFeg6JvcBu0A4=";
  };

  patches = [ ./hardcode_mtab.patch ];

  configureFlags = [
    "--enable-drivers=all"
    "--enable-lcdproc-menus"
    "--with-pidfile-dir=/run"
  ];

  buildInputs = [ freetype libX11 libftdi libusb1 ncurses ]; # libusb-compat-0_1

  nativeBuildInputs = [ autoreconfHook doxygen makeWrapper pkg-config ];

  # In 0.5.9: gcc: error: libbignum.a: No such file or directory
  # enableParallelBuilding = false;

  postFixup = ''
    for f in $out/bin/*.pl ; do
      substituteInPlace $f \
        --replace /usr/bin/perl ${stdenv.lib.getBin perl}/bin/perl
    done

    # NixOS will not use this file anyway but at least we can now execute LCDd
    substituteInPlace $out/etc/LCDd.conf \
      --replace server/drivers/ $out/lib/lcdproc/
  '';

  meta = with stdenv.lib; {
    description = "Client/server suite for controlling a wide variety of LCD devices";
    homepage = "http://lcdproc.org/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
