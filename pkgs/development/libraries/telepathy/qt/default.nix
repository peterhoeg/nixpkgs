{ stdenv, fetchFromGitHub, cmake, qtbase, pkgconfig, doxygen, python2Packages, dbus_glib, dbus_daemon
, telepathy_farstream, telepathy_glib, pcre }:

let
  inherit (python2Packages) python dbus-python;

in stdenv.mkDerivation rec {
  name = "telepathy-qt-${version}";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "TelepathyIM";
    repo = "telepathy-qt";
    rev = "${name}";
    sha256 = "1d1xlmvs079rdrandfiy24bzjy3d9sp3pvrxk1y9akyfjfzm314p";
  };

  nativeBuildInputs = [ cmake doxygen pkgconfig python ];

  buildInputs = [ dbus_daemon qtbase dbus_glib telepathy_farstream pcre telepathy_glib dbus-python ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DDESIRED_QT_VERSION=${builtins.substring 0 1 qtbase.version}"
  ];

  doCheck = false; # giving up for now

  meta = with stdenv.lib; {
    homepage = http://telepathy.freedesktop.org;
    platforms = platforms.linux;
  };
}
