{ stdenv, buildPythonPackage, fetchPypi
, requests }:

buildPythonPackage rec {
  pname = "WazeRouteCalculator";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1fcsh2vbj6dks60b0sdwchrvdgjqblxicxh5xzmf5x2l0h489rbi";
  };

  propagatedBuildInputs = [ requests ];

  # there are no tests
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Calculate actual route time and distance with Waze API";
    homepage = https://github.com/kovacsbalu/WazeRouteCalculator;
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
