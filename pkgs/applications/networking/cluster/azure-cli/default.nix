{ stdenv, pythonPackages }:

let
  pname = "azure-cli";

in pythonPackages.buildPythonApplication rec {
  name = "${pname}-${version}";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "111xhjma4a0k7gq58hbqglhb3rai0a576azz7g8gmqjr3kl0264v";
  };

  propagatedBuildInputs = with pythonPackages; [ pycrypto ];

  meta = with stdenv.lib; {
    homepage = https://code.google.com/p/volatility;
    description = "Advanced memory forensics framework";
    maintainers = with maintainers; [ bosu ];
    license = stdenv.lib.licenses.gpl2Plus;
  };
}
