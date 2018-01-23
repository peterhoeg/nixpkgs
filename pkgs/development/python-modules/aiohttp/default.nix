{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, chardet
, multidict
, async-timeout
, yarl
, pytest
, gunicorn
, pytest-raisesregexp
}:

buildPythonPackage rec {
  name = "${pname}-${version}";
  version = "2.3.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "af5bfdd164256118a0a306b3f7046e63207d1f8cba73a67dcc0bd858dcfcd3bc";
  };

  disabled = pythonOlder "3.4";

  doCheck = false; # Too many tests fail.

  checkInputs = [ pytest gunicorn pytest-raisesregexp ];
  propagatedBuildInputs = [ async-timeout chardet multidict yarl ];

  meta = {
    description = "Http client/server for asyncio";
    license = with lib.licenses; [ asl20 ];
    homepage = https://github.com/KeepSafe/aiohttp/;
  };
}
