{ buildPythonPackage
, fetchPypi
, lib
, serpent
, pythonOlder
, pytest
}:

let
  # ignore network related tests, which fail in sandbox
  ignoredTests = [ "StartNSfunc" "Broadcast" "GetIP" ];

in
buildPythonPackage rec {
  pname = "Pyro5";
  version = "5.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02i3g35hjrvkiyjaskm2r5zrp3sjgxs8himksb0f6n093vg3lhrl";
  };

  propagatedBuildInputs = [ serpent ];

  disabled = pythonOlder "3.6";

  checkInputs = [ pytest ];

  checkPhase = ''
    pytest -k '${lib.concatMapStringsSep " and " (e: "not ${e}") ignoredTests}'
  '';

  meta = with lib; {
    description = "Distributed object middleware for Python (RPC)";
    homepage = "https://github.com/irmen/Pyro5";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
