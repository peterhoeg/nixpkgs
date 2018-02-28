{ stdenv, buildPythonPackage, fetchPypi
, aiohttp, aiohttp-jinja2, astral, async, bcrypt, configparser, daemonize
, feedparser, iso8601, jinja2, pyyaml, requests, sseclient
, voluptuous, websocket-client, yarl }:

buildPythonPackage rec {
  pname = "appdaemon";
  version = "3.0.0b3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0rv05j2lq0aialmia6yscfpyjlip193xrabkmnw383641xnw41lg";
  };

  propagatedBuildInputs = [
    aiohttp aiohttp-jinja2 astral async bcrypt configparser daemonize feedparser iso8601
    jinja2 pyyaml requests sseclient voluptuous websocket-client yarl
  ];

  meta = with stdenv.lib; {
    description = "Sandboxed python execution environment for writing automation apps for Home Assistant";
    homepage = https://home-assistant.io;
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
