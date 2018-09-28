{ stdenv, fetchurl, openssl, pcre, gperftools }:

stdenv.mkDerivation rec {
  name = "pound-${version}";
  version = "2.8";

  src = fetchurl {
    url = "http://www.apsis.ch/pound/Pound-${version}.tgz";
    sha256 = "098c903k5kbyq1cndpcpxyw499anzm5hzzbrbrhr1lqgvs88dzd7";
  };

  postPatch = ''
    substituteInPlace Makefile.in \
      --replace '-o @I_OWNER@ -g @I_GRP@' ""
  '';

  configureFlags = [
    "--sysconfdir=/etc"
  ];

  buildInputs = [
    openssl pcre gperftools
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Reverse proxy, load balancer and HTTPS front-end for Web server(s)";
    homepage = http://www.apsis.ch/pound/;
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
