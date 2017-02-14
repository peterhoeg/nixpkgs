{ stdenv, fetchFromGitHub, autoconf, automake, doxygen, pkgconfig, libiconv, openssl, swig, zlib, which
, withIcu ? false, icu
, withPerl ? true, perl
, withPython ? true, python3
, withTcl ? false, tcl
, withCyrus ? true, cyrus_sasl
}:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "znc-${version}";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "znc";
    repo = "znc";
    rev = "znc-${version}";
    sha256 = "1gnh4qk3qhpw6q419g8rnn35hkm7c2m14fkmwf1g13b42i7h1hwl";
  };

  buildInputs = [ openssl zlib ]
    ++ optional withIcu icu
    ++ optional withTcl tcl
    ++ optional withCyrus cyrus_sasl
    ++ optionals withPerl [ swig perl ]
    ++ optionals withPython [ swig python3 ];

  nativeBuildInputs = [ autoconf automake doxygen pkgconfig which ];

  preConfigure = "./autogen.sh";

  configureFlags = optionalString withPerl "--enable-perl "
    + optionalString withPython "--enable-python "
    + optionalString withTcl "--enable-tcl --with-tcl=${tcl}/lib "
    + optionalString withCyrus "--enable-cyrus ";

  meta = with stdenv.lib; {
    description = "Advanced IRC bouncer";
    homepage = http://wiki.znc.in/ZNC;
    maintainers = with maintainers; [ viric schneefux ];
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
