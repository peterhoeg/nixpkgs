{ stdenv, lib, fetchFromGitHub, python2, gettext }:

let
  # pin requests version until next release.
  # see: https://github.com/linkcheck/linkchecker/issues/76
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

  ignoredFiles = [
    "test_clamav.py"
  ];

  ignoredTests = [
    "checker/test_http_misc.py::TestHttpMisc"
    "checker/test_file.py::TestFile"
  ];

in python2Packages.buildPythonApplication rec {
  pname = "LinkChecker";
  version = "9.4.0";

  propagatedBuildInputs = (with python2Packages; [
    dnspython pyxdg requests
  ]) ++ [ gettext ];

  checkInputs = with python2Packages; [ pytest ];

  # the original repository is abandoned, development is now happening here:
  src = fetchFromGitHub {
    owner = "linkcheck";
    repo = "linkchecker";
    rev = "v${version}";
    sha256 = "1vbwl2vb8dyzki27z3sl5yf9dhdd2cpkg10vbgaz868dhpqlshgs";
  };

  preConfigure = ''
    mv README.rst README.txt

    python setup.py sdist --manifest-only
  '';

  prePatch = ''
    substituteInPlace Makefile \
      --replace 'TESTOPTS=' 'TESTOPTS=${lib.concatStringsSep " " (map (e: "--deselect=tests/${e}") ignoredTests)} ${lib.concatStringsSep " " (map (e: "--ignore=tests/${e}") ignoredFiles)}'
    export HOME=$TMP
  '';

  checkTarget = "test";

  meta = with lib; {
    description = "Check websites for broken links";
    homepage = https://linkcheck.github.io/linkchecker/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg tweber ];
  };
}
