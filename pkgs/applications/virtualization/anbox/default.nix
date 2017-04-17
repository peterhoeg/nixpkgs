{ stdenv, fetchFromGitHub, cmake, ecm, pkgconfig
, dbus, dbus_cplusplus, libcap
, pkgs }:

stdenv.mkDerivation rec {
  name = "anbox-git-${version}";
  version = "2017-04-13";

  src = fetchFromGitHub {
    owner  = "anbox";
    repo   = "anbox";
    rev    = "120bd0797526d9cfc91d59ac5c7170d5b6cb7317";
    sha256 = "13ipxr7xsz1gaa8k4bq7xk0xlf5swalwszbhbc4inafcw7qsr83m";

  };

  buildInputs = [
    dbus dbus_cplusplus
  ] ++ (with pkgs; [
    boost libdrm mesa protobuf SDL2
  ]) ++ (with pkgs.xorg; [
    libpthreadstubs
    libX11
    libXdamage
    libXdmcp
  ]);

  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    "-DDBUS_CPP_INCLUDE_DIRS=${dbus_cplusplus}/include/dbus-c++-1:${dbus_cplusplus}/lib"
    "-DDBUS_CPP_LIBRARIES=${dbus_cplusplus}/lib/libdbus-c++-1.so"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A container based approach to boot a full Android system on GNU/Linux";
    homepage    = https://github.com/anbox/anbox;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
