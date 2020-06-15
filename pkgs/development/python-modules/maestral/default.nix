{ stdenv
, fetchFromGitHub
, python
, sdnotify
, systemd
}:
python.pkgs.buildPythonApplication rec {
  pname = "maestral";
  version = "1.1.0";

  disabled = python.pkgs.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "SamSchott";
    repo = "maestral";
    rev = "v${version}";
    sha256 = "0d1pxbg69ll07w4bbpzs7zz1yn82qyrym95b0mqmhrrg2ysxjngg";
  };

  propagatedBuildInputs = with python.pkgs; [
    blinker
    bugsnag
    click
    dropbox
    fasteners
    keyring
    keyrings-alt
    pathspec
    Pyro5
    requests
    u-msgpack-python
    watchdog
  ] ++ stdenv.lib.optionals stdenv.isLinux [
    sdnotify
    systemd
  ];

  makeWrapperArgs = [
    # Add the installed directories to the python path so the daemon can find them
    "--prefix" "PYTHONPATH" ":" "${stdenv.lib.concatStringsSep ":" (map (p: p + "/lib/${python.libPrefix}/site-packages") (python.pkgs.requiredPythonModules propagatedBuildInputs))}"
    "--prefix" "PYTHONPATH" ":" "$out/lib/${python.libPrefix}/site-packages"
  ];

  # no tests
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Open-source Dropbox client for macOS and Linux";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
    inherit (src.meta) homepage;
  };
}
