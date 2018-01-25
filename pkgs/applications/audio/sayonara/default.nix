{ stdenv, lib, fetchurl, cmake, pkgconfig
, dbus, glib, pcre, qtbase, qttools, qt-gstreamer, taglib, zlib
, gstreamer, gst-plugins-base, gst-plugins-good, gst-plugins-ugly, gst-libav }:

let
  releaseDate = "20180115";

in stdenv.mkDerivation rec {
  name = "sayonara-player-${version}";
  version = "1.0.0";

  src = fetchurl {
    url = "http://sayonara-player.com/sw/${name}-git5-${releaseDate}.tar.gz";
    sha256 = "1fl7zplnrrvbv1xm4g348bpd46jj39jvbm808hyjjq92i64wqg37";
  };

  nativeBuildInputs = [ cmake pkgconfig qttools ];

  buildInputs = [
    glib pcre qtbase qt-gstreamer taglib zlib
    gstreamer gst-plugins-base gst-plugins-good gst-plugins-ugly gst-libav
  ] ++ lib.optional stdenv.isLinux dbus;

  # enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A multiplatform music player";
    homepage = https://sayonara-player.com;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
