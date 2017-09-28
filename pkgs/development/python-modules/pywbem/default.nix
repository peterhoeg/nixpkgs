{ stdenv, buildPythonPackage, fetchFromGitHub, fetchpatch, libxml2, which
, m2crypto, ply, pyyaml, six
, httpretty, lxml, mock, pytest, pytestcov, requests
}:

buildPythonPackage rec {
  name  = "pywbem-${version}";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner  = "pywbem";
    repo   = "pywbem";
    rev    = "v${version}";
    sha256 = "01lwgzmq04rska03qmfhmzbwx3gl1v8nsky3iwfzr3xr5zm1hvd7";
  };

  buildInputs = [ libxml2 ];

  nativeBuildInputs = [ which ];

  propagatedBuildInputs = [ m2crypto ply pyyaml six ];

  checkInputs = [ httpretty lxml mock pytestcov pytest requests ];

  # 1 test fails because it doesn't like running in our sandbox. Deleting the
  # whole file is admittedly a little heavy-handed but at least the vast
  # majority of tests are run.
  checkPhase = ''
    # rm testsuite/testclient/networkerror.yaml

    # substituteInPlace makefile \
      # --replace "PYTHONPATH=." "" \
      # --replace '--cov $(package_name) --cov-config coveragerc' ""

    for f in testsuite/test_cim_xml.py testsuite/validate.py ; do
      substituteInPlace $f --replace "'xmllint" "'${stdenv.lib.getBin libxml2}/bin/xmllint"
    done

    # make PATH=$PATH:${stdenv.lib.getBin libxml2}/bin test
    make test
  '';

  meta = with stdenv.lib; {
    description = "Support for the WBEM standard for systems management.";
    homepage    = http://pywbem.github.io/pywbem/;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
