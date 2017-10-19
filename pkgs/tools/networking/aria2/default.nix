{ stdenv, fetchFromGitHub, pkgconfig, autoreconfHook
, openssl, c-ares, libxml2, sqlite, zlib, libssh2
, Security
}:

stdenv.mkDerivation rec {
  name = "aria2-${version}";
  version = "1.33.0";

  src = fetchFromGitHub {
    owner = "aria2";
    repo = "aria2";
    rev = "release-${version}";
    sha256 = "07i9wrj7bs9770ppx943zgn8j9zvffxg2pib4w5ljxapqldhwrsq";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ openssl c-ares libxml2 sqlite zlib libssh2 ] ++
    stdenv.lib.optional stdenv.isDarwin Security;

  enableParallelBuilding = true;

  configureFlags = [
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    "--with-bashcompletiondir=$(out)/share/bash-completion/completions"
  ];

  postInstall = ''
    mv $out/share/doc/aria2/xmlrpc/aria* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "A lightweight, multi-protocol, multi-source, command-line download utility";
    homepage    = https://aria2.github.io;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ koral jgeerds ];
    platforms   = platforms.unix;
  };
}
