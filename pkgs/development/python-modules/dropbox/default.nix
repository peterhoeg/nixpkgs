{ stdenv, buildPythonPackage, fetchPypi
, pytestrunner, requests, urllib3, mock, setuptools }:

buildPythonPackage rec {
  pname = "dropbox";
  version = "10.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "012g3dsjm5aacgxn9gi2izh8alqn8jp3da8vpmmw89ns36lv42qx";
  };

  # Set DROPBOX_TOKEN environment variable to a valid token.
  doCheck = false;

  buildInputs = [ pytestrunner ];
  propagatedBuildInputs = [ requests urllib3 mock setuptools ];

  meta = with stdenv.lib; {
    description = "A Python library for Dropbox's HTTP-based Core and Datastore APIs";
    homepage = "https://www.dropbox.com/developers/core/docs";
    license = licenses.mit;
  };
}
