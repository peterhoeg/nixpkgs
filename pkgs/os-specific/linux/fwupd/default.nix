{ stdenv, fetchFromGitHub, autoreconfHook, intltool, libxslt, gtk_doc, pkgconfig }:

stdenv.mkDerivation rec {
  name = "fwupd-${version}";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "fwupd";
    rev = "${version}";
    sha256 = "0sgga2cixz8jiz47wjj56igam1mb3rzr48zqhr2ibig8iiwkq1j1";
  };

  buildInputs = [ libxslt ];

  nativeBuildInputs = [ autoreconfHook gtk_doc intltool libxslt pkgconfig ];

  preAutoreconf = ''
    cp ${gtk_doc}/share/gtk-doc/data/gtk-doc.make .
    export WARN_CFLAGS_EXTRA=""
    export WARN_CFLAGS=""
  '';

  meta = with stdenv.lib; {
    homepage     = https://www.wireguard.io/;
    downloadPage = https://git.zx2c4.com/WireGuard/refs/;
    description  = "Fast, modern, secure VPN tunnel";
    maintainers  = with maintainers; [ ericsagnes ];
    license      = licenses.gpl2;
    platforms    = platforms.linux;
  };
}
