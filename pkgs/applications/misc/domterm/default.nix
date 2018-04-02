{ stdenv, lib, fetchFromGitHub, autoreconfHook, asciidoctor, pkgconfig, zip
, qtbase, qtwebengine
, json_c, libuv, libwebsockets, openssl, zlib }:

stdenv.mkDerivation rec {
  name = "domterm-${version}";
  version = "1.0";

  src = fetchFromGitHub {
    owner  = "PerBothner";
    repo   = "domterm";
    rev    = "${version}";
    sha256 = "1v6g059i4hi55gz33alrnklix72d2q7xcfqzsr91w5nqi2angypm";
  };

  nativeBuildInputs = [
    asciidoctor autoreconfHook pkgconfig zip
  ];

  buildInputs = [
    qtbase qtwebengine
    json_c libuv libwebsockets openssl zlib
  ];

  enableParallelBuilding = true;

  configureFlags = [
    "--with-qtwebengine"
  ];

  meta = with stdenv.lib; {
    description = "Terminal emulator, REPL console, and screen multiplexer";
    homepage    = https://domterm.org/;
    license     = with licenses; [ free ];
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
