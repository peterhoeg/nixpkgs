{ lib, buildPythonPackage, fetchPypi, nose
, zlib }:

# The only user of this is "appdaemon" and we should drop it when appdaemon moves away from it:
# https://github.com/home-assistant/appdaemon/issues/246

buildPythonPackage rec {
  pname = "async";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0l9h6kc2j8palv08li1lfd0yqa0f3pv0qfs9mvx7hn74fvc98s5c";
  };

  buildInputs = [ zlib ];

  checkInputs = [ nose ];

  meta = with lib; {
    description = "DEPRECATED: Framework to process interdependent tasks in a pool of workers";
    longDescription = ''
      This framework is deprecated and really shouldn't be used.
    '';
    homepage = https://pypi.python.org/pypi/async;
    license = licenses.bsd3;
  };
}
