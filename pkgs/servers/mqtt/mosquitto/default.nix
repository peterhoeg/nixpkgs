{ stdenv, fetchFromGitHub, fetchurl, cmake, docbook_xsl, libxslt
, openssl, libuuid, libwebsockets, c-ares, libuv }:

stdenv.mkDerivation rec {
  name = "mosquitto-${version}";
  version = "1.5.6";

  src = fetchurl {
    url = "https://mosquitto.org/embargo/78436548/${name}.tar.gz";
    sha256 = "0h0sfph1azb3fxv70h38kw1fxahhvqagqmvd6wk00db8qqyc3gfm";
  };

  # TODO: switch back to this when normal releases are available at GH again
  # src = fetchFromGitHub {
  #   owner  = "eclipse";
  #   repo   = "mosquitto";
  #   rev    = "v${version}";
  #   sha256 = "1sfwmvrglfy5gqfk004kvbjldqr36dqz6xmppbgfhr47j5zs66xc";
  # };

  buildInputs = [ openssl libuuid libwebsockets c-ares libuv ];

  nativeBuildInputs = [ cmake docbook_xsl libxslt ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DWITH_THREADING=ON"
    "-DWITH_WEBSOCKETS=ON"
  ];

  meta = with stdenv.lib; {
    description = "An open source MQTT v3.1/3.1.1 broker";
    homepage = http://mosquitto.org/;
    license = licenses.epl10;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
