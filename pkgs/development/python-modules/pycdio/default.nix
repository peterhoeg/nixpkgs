{ stdenv, buildPythonPackage, fetchPypi, nose, pkgconfig, setuptools, swig
, libcdio, libiconv }:

buildPythonPackage rec {
  pname = "pycdio";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a1h0lmfl56a2a9xqhacnjclv81nv3906vdylalybxrk4bhrm3hj";
  };

  # prePatch = ''
    # sed -i -e "s|if type(driver_id)==int|if type(driver_id) in (int, long)|g" cdio.py
  # '';

  # preConfigure = ''
    # patchShebangs .
  # '';

  nativeBuildInputs = [ pkgconfig setuptools swig ];

  buildInputs = [ libcdio ]
    ++ stdenv.lib.optional stdenv.isDarwin libiconv;

  checkInputs = [ nose ];

  # Run tests using nosetests but first need to install the binaries
  # to the root source directory where they can be found.
  checkPhase = ''
    ./setup.py install_lib -d .
    nosetests
  '';

  meta = with stdenv.lib; {
    description = "Wrapper around libcdio (CD Input and Control library)";
    homepage = http://www.gnu.org/software/libcdio/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ rycee ];
  };
}
