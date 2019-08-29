{ stdenv, fetchurl, pkgconfig, libzip, glib, libusb1, libftdi1, check
, libserialport, librevisa, doxygen, glibmm, python
, version ? "0.5.1", sha256 ? "171b553dir5gn6w4f7n37waqk62nq2kf1jykx4ifjacdz5xdw3z4"
}:

stdenv.mkDerivation rec {
  pname = "libsigrok";
  inherit version;

  src = fetchurl {
    url = "https://sigrok.org/download/source/${pname}/${pname}-${version}.tar.gz";
    inherit sha256;
  };

  firmware = fetchurl {
    url = "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-0.1.6.tar.gz";
    sha256 = "14sd8xqph4kb109g073daiavpadb20fcz7ch1ipn0waz7nlly4sw";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ libzip glib libusb1 libftdi1 check libserialport
    librevisa doxygen glibmm python
  ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p "$out/share/sigrok-firmware/"
    tar --strip-components=1 -xvf "${firmware}" -C "$out/share/sigrok-firmware/"
    install -Dm444 -t $out/lib/udev/rules.d contrib/*.rules
  '';

  meta = with stdenv.lib; {
    description = "Core library of the sigrok signal analysis software suite";
    homepage = "https://sigrok.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ bjornfor ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
