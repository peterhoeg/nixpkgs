{ stdenv, fetchFromGitHub, qmake
, openzwave, qtbase }:

stdenv.mkDerivation rec {
  name = "ozw-admin-${version}";
  version = "20180321";

  src = fetchFromGitHub {
    owner  = "OpenZWave";
    repo   = "ozw-admin";
    rev    = "cd386efdd095e5cdfe4e07ccc46c3f68f95e13fe";
    sha256 = "02qlhann665b4590c47h93q0fplr7kargddxl9z84ig2m2pjlq7i";
  };

  postPatch = ''
    rmdir open-zwave
    # ln -s
  '';

  buildInputs = [ openzwave qtbase ];

  nativeBuildInputs = [ qmake ];

  # NIX_CFLAGS_COMPILE="-I ${openzwavedev}/include";

  meta = with stdenv.lib; {
    homepage = https://www.owasp.org/index.php/ZAP;
    description = "Java application for web penetration testing";
    maintainers = with maintainers; [ mog ];
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}
