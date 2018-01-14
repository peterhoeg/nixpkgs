{ stdenv, fetchPypi, buildPythonPackage }:

buildPythonPackage rec {
  pname = "home-assistant-frontend";
  version = "20180126.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0fnx9zh3zm5gvikz6hmrc1q2blsqkihs2n5z3gm4yzprd4x1r5qx";
  };
}
