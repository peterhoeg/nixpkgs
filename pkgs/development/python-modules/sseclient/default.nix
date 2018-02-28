{ stdenv, buildPythonPackage, fetchPypi
, requests, six
, backports_unittest-mock, pluggy, pytest, pytestrunner }:

# When upgrading this to 0.0.19 or later, re-enable tests
# https://github.com/btubbs/sseclient/pull/12

buildPythonPackage rec {
  pname = "sseclient";
  version = "0.0.18";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1n9f3rqrkzig27v0iki2flf56z4g4pwych40j1d82pf3p0bsyq0p";
  };

  propagatedBuildInputs = [ requests six ];

  # it doesn't find any tests to run and then errors out
  doCheck = false;

  checkInputs = [ backports_unittest-mock pytest pytestrunner ];

  meta = with stdenv.lib; {
    description = "Client library for reading Server Sent Event streams";
    homepage = https://github.com/btubbs/sseclient;
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
