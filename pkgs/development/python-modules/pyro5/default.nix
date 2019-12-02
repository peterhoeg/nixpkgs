{ buildPythonPackage
, fetchPypi
, lib
, serpent
, pythonOlder
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "Pyro5";
  version = "5.6";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02i3g35hjrvkiyjaskm2r5zrp3sjgxs8himksb0f6n093vg3lhrl";
  };

  propagatedBuildInputs = [ serpent ];

  checkInputs = [ pytestCheckHook ];

  # ignore network related tests, which fail in sandbox
  disabledTests = [ "StartNSfunc" "Broadcast" "GetIP" ];

  meta = with lib; {
    description = "Distributed object middleware for Python (RPC)";
    homepage = "https://github.com/irmen/Pyro5";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
