{ lib, python3Packages, fetchFromGitHub }:

with python3Packages;

buildPythonApplication rec {
  pname = "pwgen_secure";
  version = "0.9.1";

  # GH is newer than Pypi and contains both library *and* the actual program
  # whereas Pypi only has the library
  src = fetchFromGitHub {
    owner = "mjmunger";
    repo = "pwgen_secure";
    rev = "v${version}";
    sha256 = "15md5606hzy1xfhj2lxmc0nvynyrcs4vxa5jdi34kfm31rdklj28";
  };

  propagatedBuildInputs = [ docopt ];

  postInstall = ''
    install -Dm755 spwgen.py $out/bin/spwgen
  '';

  meta = with lib; {
    description = "Secure password generation library to replace pwgen";
    homepage = https://github.com/mjmunger/pwgen_secure/;
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
