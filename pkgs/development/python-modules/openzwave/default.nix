{ stdenv, buildPythonPackage, fetchPypi, pkgconfig, libopenzwave, cython, six }:

buildPythonPackage rec {
  pname = "python_openzwave";
  version = "0.4.4";

  src = fetchPypi {
    inherit pname version;
    extension = "zip";
    sha256 = "17wdgwg212agj1gxb2kih4cvhjb5bprir4x446s8qwx0mz03azk2";
  };

  buildInputs = [ libopenzwave ];

  nativeBuildInputs = [ pkgconfig ];

  propagatedBuildInputs = [ cython six ];

  meta = with stdenv.lib; {
    description = "Python wrapper for openzwave";
    inherit (libopenzwave.meta) homepage license maintainers;
  };
}
