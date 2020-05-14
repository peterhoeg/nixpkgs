{ stdenv
, python
, fetchFromGitHub
, sdnotify
, systemd
}:
let

  pbi = with python.pkgs; [
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
  ] ++ stdenv.lib.optionals stdenv.isLinux [
    sdnotify
    systemd
  ];

  path = stdenv.lib.makeLibraryPath pbi;
in


python.pkgs.buildPythonApplication rec {
  pname = "maestral";
  version = "1.0.2";

  disabled = python.pkgs.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "SamSchott";
    repo = "maestral";
    rev = "v${version}";
    sha256 = "16wmw7ximdlbv8vzc57xjrki0df29mps5r9xwx7iifbvp9n0m0cl";
  };

  propagatedBuildInputs = pbi;

  makeWrapperArgs = [
    # Firstly, add all necessary QT variables
    # "\${qtWrapperArgs[@]}"

    "--prefix" "PYTHONPATH" ":" "${path}"

    "--prefix" "PYTHONPATH" ":" "$out/lib/${python.libPrefix}/site-packages"

    # # Then, add the installed scripts/ directory to the python path
    # "--prefix" "PYTHONPATH" ":" "${python.pkgs.maestral}/lib/${python.libPrefix}/site-packages"
    # "--prefix" "PYTHONPATH" ":" "${python.pkgs.Pyro5}/lib/${python.libPrefix}/site-packages"
    # "--prefix" "PYTHONPATH" ":" "${python.pkgs.serpent}/lib/${python.libPrefix}/site-packages"

    # finally, move to directory that contains data
    # "--run" "\"cd $out/share/${pname}\""
  ];


  # postPatch = ''
  #   # sdnotify is correctly passed in buildInputs, but for some reason setup.py complains.
  #   # The wrapped maestral has the correct path added, so ignore this.
  #   substituteInPlace setup.py --replace "'sdnotify'," ""
  # '';

  #  ++ lib.optional withGui pyqt5;

  # nativeBuildInputs = lib.optional withGui wrapQtAppsHook;

  # postInstall = lib.optionalString withGui ''
  #   makeQtWrapper $out/bin/maestral $out/bin/maestral-gui \
  #     --add-flags gui
  # '';

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
