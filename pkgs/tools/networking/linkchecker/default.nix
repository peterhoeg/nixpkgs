{ stdenv, lib, fetchFromGitHub, fetchpatch, python2, gettext }:
let
  # 9.4.0 requires requests < 2.15
  python2Packages = (python2.override {
    packageOverrides = self: super: {
      requests = super.requests.overridePythonAttrs(oldAttrs: rec {
        version = "2.14.2";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "0lyi82a0ijs1m7k9w1mqwbmq1qjsac35fazx7xqyh8ws76xanx52";
        };
      });
    };
  }).pkgs;

in python2Packages.buildPythonApplication rec {
  pname = "LinkChecker";
  version = "9.4.0-2";

  propagatedBuildInputs = (with python2Packages; [
    argparse
    dnspython
    pyxdg
    requests
  ]) ++ [ gettext ];

  checkInputs = with python2Packages; [ pytest ];

  src = fetchFromGitHub {
    owner  = "linkchecker";
    repo   = "linkchecker";
    rev    = "debian/${version}";
    sha256 = "1g8a6ykwm3l6ygy1hzrqjhpn39lis2sziaqp49yzzav75lc07xyb";
  };

  # Many tests are not running with the latest version but based on manual
  # testing, this version is fine.
  doCheck = false;

  meta = with lib; {
    description = "Check websites for broken links";
    homepage = https://linkchecker.github.io/linkchecker/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg tweber ];
  };
}
