{ stdenv
, lib
, python3Packages
, fetchFromGitHub
, withGui ? false
, wrapQtAppsHook ? null
}:

python3Packages.buildPythonApplication rec {
  pname = "maestral${lib.optionalString withGui "-gui"}";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "SamSchott";
    repo = "maestral-dropbox";
    rev = "v${version}";
    sha256 = "0br2njzbzb2qa7rj0biysnhgxgkdla88wbn7r3rwl9na0x91q1k4";
  };

  disabled = python3Packages.pythonOlder "3.6";

  propagatedBuildInputs = with python3Packages; [
    blinker
    click
    dropbox
    keyring
    keyrings-alt
    Pyro5
    requests
    u-msgpack-python
    watchdog
  ] ++ lib.optionals stdenv.isLinux [
    sdnotify
    systemd
  ] ++ lib.optional withGui pyqt5;

  nativeBuildInputs = lib.optional withGui wrapQtAppsHook;

  postInstall = lib.optionalString withGui ''
    makeQtWrapper $out/bin/maestral $out/bin/maestral-gui \
      --add-flags gui
  '';

  # no tests
  doCheck = false;

  meta = with lib; {
    description = "Open-source Dropbox client for macOS and Linux";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
    inherit (src.meta) homepage;
  };
}
