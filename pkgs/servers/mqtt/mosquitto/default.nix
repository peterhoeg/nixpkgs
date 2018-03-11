{ stdenv, lib, fetchurl, openssl, libuuid, cmake, libwebsockets, c-ares, libuv }:

stdenv.mkDerivation rec {
  name = "mosquitto-${version}";
  version = "1.4.15";

  src = fetchurl {
    url = "http://mosquitto.org/files/source/${name}.tar.gz";
    sha256 = "10wsm1n4y61nz45zwk4zjhvrfd86r2cq33370m5wjkivb8j3wfvx";
  };

  buildInputs = [ openssl libuuid libwebsockets c-ares libuv ];

  nativeBuildInputs = [ cmake ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace config.mk \
      --replace "/usr/local" "" \
      --replace "WITH_WEBSOCKETS:=no" "WITH_WEBSOCKETS:=yes"

    for d in lib lib/cpp src ; do
      substituteInPlace $d/CMakeLists.txt \
        --replace /sbin/ldconfig ldconfig
    done
  '';

  meta = with lib; {
    description = "An open source MQTT v3.1/3.1.1 broker";
    homepage    = https://mosquitto.org/;
    # http://www.eclipse.org/legal/epl-v10.html (free software, copyleft)
    license     = licenses.epl10;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
