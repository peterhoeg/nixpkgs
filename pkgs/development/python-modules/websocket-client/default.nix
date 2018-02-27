{ stdenv, buildPythonPackage, fetchPypi
, six }:

buildPythonPackage rec {
  pname = "websocket_client";
  version = "0.47.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0jb1446053ryp5p25wsr1hjfdzwfm04a6f3pzpcb63bfz96xqlx4";
  };

  propagatedBuildInputs = [ six ];

  meta = with stdenv.lib; {
    description = "WebSocket client for python with hybi13 support";
    homepage = https://github.com/websocket-client/websocket-client;
    license = licenses.lgpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
