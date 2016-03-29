{ stdenv, fetchurl, pythonPackages }:

pythonPackages.buildPythonApplication rec {
  version = "2.4.3";
  name = "Shinken-${version}";

  # Python 3 is not supported
  disabled = pythonPackages.isPy3k;

  src = fetchurl {
    url = "mirror://pypi/s/shinken/${name}.tar.gz";
    sha256 = "1hxbnxlk2bacb7p6lim9kqy50581m0d3p3y6b9hw0x800lfk0y6q";
  };

  # no binaries to strip
  dontStrip = true;

  # missing: logging tagging

  propagatedBuildInputs = with pythonPackages; [
    arrow bottle cffi cherrypy django paramiko pycurl pymongo pyopenssl
  ];

  # checkPhase = ''
  #     cd $out/test
  #     ./quick_test.sh
  #   '';

  meta = with stdenv.lib; {
    homepage = http://www.shinken-monitoring.org/;
    description = "A monitoring framework compatible with Nagios configuration and plugins";
    license = licenses.agpl3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
