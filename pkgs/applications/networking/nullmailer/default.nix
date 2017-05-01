{ stdenv, lib, fetchurl, autoreconfHook
, gnutls }:

stdenv.mkDerivation rec {
  name = "nullmailer-${version}";
  version = "2.0";

  src = fetchurl {
    url = "https://untroubled.org/nullmailer/${name}.tar.gz";
    sha256 = "112ghdln8q9yljc8kp9mc3843mh0fyb4rig2v4q2dzy1l324q3yp";
  };

  buildInputs = [ gnutls ];
  nativeBuildInputs = [ autoreconfHook ];
  enableParallelBuild = true;

  configureFlags = [
    "--enable-tls"
  ];

  postInstall = ''
    rm -rf $out/{etc,var}
  '';

  meta = with stdenv.lib; {
    description = "Simple and easy to use SMTP client with excellent sendmail compatibility";
    homepage = "http://msmtp.sourceforge.net/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
