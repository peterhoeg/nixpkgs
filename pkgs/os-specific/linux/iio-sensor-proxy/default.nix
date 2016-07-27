{ stdenv, fetchFromGitHub
, glib, gnome3, gtk_doc, libgudev, pkgconfig, systemd, which }:

let
  project = "iio-sensor-proxy";
  version = "1.1";

in stdenv.mkDerivation rec {
  inherit version;
  name = "${project}-${version}";

  src = fetchFromGitHub {
    owner = "hadess";
    repo = project;
    rev = version;
    sha256 = "0m4nr1haqf8ps63x6kgi7vvjl127pq3nbajnlydq96b072cqdkxi";
  };

  buildInputs = [
    glib
    gnome3.gnome_common
    gtk_doc
    systemd
    libgudev
    pkgconfig
    which
  ];

  configurePhase = ''
    ./autogen.sh
    ./configure --prefix=$out \
      --with-udevrulesdir=$out/lib/udev/rules.d \
      --with-systemdsystemunitdir=$out/lib/systemd/system
  '';

  meta = with stdenv.lib; {
    inherit version;
    description = "Proxy for sending IIO sensor data to D-Bus";
    license = licenses.gpl3 ;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = stdenv.lib.platforms.linux;
  };
}
