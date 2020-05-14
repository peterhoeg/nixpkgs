{ stdenv
, lib
, fetchFromGitHub
, python3
, wrapQtAppsHook
}:

let pbi = with python3.pkgs; [
    bugsnag
    click
    markdown2
    maestral
    pyqt5
    ] ++ (with python.pkgs; [
    blinker
    bugsnag
    click
    dropbox
    keyring
    keyrings-alt
    lockfile
    pathspec
    Pyro5
    requests
    u-msgpack-python
    watchdog
    ]) ++ stdenv.lib.optionals stdenv.isLinux [
    sdnotify
    systemd
  ];

in

python3.pkgs.buildPythonApplication rec {
  pname = "maestral-qt";
  version = "1.0.0";

  disabled = python3.pkgs.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "SamSchott";
    repo = "maestral-qt";
    rev = "v${version}";
    sha256 = "0izmy6vmzzzr7q9wp3zkkmcpqkwn36c7654wqsdbizr5p6z4kp80";
  };

  propagatedBuildInputs = pbi;

  nativeBuildInputs = [ wrapQtAppsHook ];

  # pythonPath = with python3.pkgs; [
  #   pyqt5
  # ];

  makeWrapperArgs = [
    # Firstly, add all necessary QT variables
    "\${qtWrapperArgs[@]}"

    # # Then, add the installed scripts/ directory to the python path
    "--prefix" "PYTHONPATH" ":" "${stdenv.lib.concatStringsSep ":" (map (p: p + "/lib/${python3.libPrefix}/site-packages") (python3.pkgs.requiredPythonModules pbi))}"
    "--prefix" "PYTHONPATH" ":" "${python3.pkgs.maestral}/lib/${python3.libPrefix}/site-packages"
    # "--prefix" "PYTHONPATH" ":" "${python3.pkgs.Pyro5}/lib/${python3.libPrefix}/site-packages"

    # Finally, move to directory that contains data
    # "--run" "\"cd $out/share/${pname}\""
  ];

  # postInstall = lib.optionalString withGui ''
  #   makeQtWrapper $out/bin/maestral $out/bin/maestral-gui \
  #     --add-flags gui
  # '';

  # no tests
  doCheck = false;

  meta = with lib; {
    description = "Open-source Dropbox client for macOS and Linux";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
    inherit (src.meta) homepage;
  };
}
