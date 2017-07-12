{ stdenv, fetchFromGitHub, cmake, ecm, pkgconfig
, boost, libtorrentRasterbar, qtbase, qttools
, guiSupport ? true, dbus_libs ? null # GUI (disable to run headless)
, webuiSupport ? true # WebUI
}:

assert guiSupport -> (dbus_libs != null);

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "qbittorrent-${version}";
  version = "3.3.13";

  src = fetchFromGitHub {
    owner  = "qbittorrent";
    repo   = "qBittorrent";
    rev    = "release-${version}";
    sha256 = "0i8gjlg7ma60197h7n8wqrg6z0j7pzgvldc5gbdibyjfp90xx74b";
  };

  buildInputs = [ boost libtorrentRasterbar qtbase qttools ]
    ++ optional guiSupport dbus_libs;
  nativeBuildInputs = [ cmake ecm pkgconfig ];

  configureFlags = [
    (if guiSupport   then "" else "-dGUI=OFF")
    (if webuiSupport then "" else "-dWEBUI=OFF")
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Free Software alternative to µtorrent";
    homepage    = http://www.qbittorrent.org/;
    license     = licenses.gpl2;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ viric ];
  };
}
