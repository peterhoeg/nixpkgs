{ stdenv, buildPythonApplication, fetchFromGitHub
, impacket, natsort, pyasn1, pycrypto }:

buildPythonApplication rec {
  pname = "py-wmi-client";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner  = "dlundgren";
    repo   = pname;
    rev    = "9702b036df85c3e0ecdde84a753b353069f58208";
    sha256 = "1kd12gi1knqv477f1shzqr0h349s5336vzp3fpfp3xl0b502ld8d";
  };

  propagatedBuildInputs = [ impacket natsort pyasn1 pycrypto ];

  meta = with stdenv.lib; {
    description = "Python WMI Client implementation";
    homepage = https://github.com/dlundgren/py-wmi-client;
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
