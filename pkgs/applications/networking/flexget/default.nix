{ lib
, python3Packages
, fetchurl
, transmission
, deluge
, config
}:

with python3Packages;

buildPythonPackage rec {
  version = "2.9.4";
  name = "FlexGet-${version}";

  src = fetchurl {
    url = "mirror://pypi/F/FlexGet/${name}.tar.gz";
    sha256 = "0fdg73h9ig58748j9zx5496y9sikdk89ma9if7zjrxrxm174gaax";
  };

  # doCheck = false;

  buildInputs = [ nose ];

  propagatedBuildInputs = [
    paver feedparser sqlalchemy pyyaml rpyc
    beautifulsoup4 html5lib_0_9999999 pyrss2gen pynzb progressbar jinja2
    flask flask-compress flask-cors flask-login flask-restful flask-restplus_0_8_6
    cherrypy requests2 dateutil jsonschema python_tvrage tmdb3
    guessit pathpy
    apscheduler colorclass future pathlib pyparsing terminaltables zxcvbn-python
  ]
  # enable deluge and transmission plugin support, if they're installed
  ++ lib.optional (config.deluge or false) deluge
  ++ lib.optional (transmission != null) transmissionrpc;

  meta = with lib; {
    homepage = http://flexget.com/;
    description = "Multipurpose automation tool for content like torrents";
    license = licenses.mit;
    maintainers = with maintainers; [ domenkozar peterhoeg ];
  };
}
