{ stdenv, lib, python2 }:

with python2.pkgs;

buildPythonApplication rec {
  pname = "azure-cli";
  version = "2.0.51";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ghjkrf4mgjdza4an7zlp82jfkafvyvva947r5k0lqbnfz9djpy9";
  };

  buildInputs = [ wheel ];

  propagatedBuildInputs = [ azure-mgmt-nspkg azure-nspkg ];

  meta = with lib; {
    description = "Fault tolerant job scheduler for Mesos which handles dependencies and ISO8601 based schedules";
    homepage    = http://airbnb.github.io/chronos;
    license     = licenses.asl20;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
