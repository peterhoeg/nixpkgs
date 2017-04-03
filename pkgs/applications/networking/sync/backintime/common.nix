{ stdenv, fetchFromGitHub, makeWrapper, which
, gettext, python3Packages, rsync, cron, openssh, sshfs-fuse, encfs }:

python3Packages.buildPythonApplication rec {
  name = "backintime-common-${version}";
  version = "1.1.18";

  # TODO: version 1.2.0 has been ported to qt5

  src = fetchFromGitHub {
    owner  = "bit-team";
    repo   = "backintime";
    rev    = "v${version}";
    sha256 = "0djkqgbb33r5rb1w99kgk61m2c3ccvnnw3pdafmyw6s9rpd126r1";
  };

  buildInputs = [ gettext openssh cron rsync sshfs-fuse encfs ];
  nativeBuildInputs = [ makeWrapper which ];
  propagatedBuildInputs = with python3Packages; [
    dbus-python keyring
  ];

  dontConfigure = true;
  dontInstall = true;
  doCheck = false;

  buildPhase = ''
    cd common
    substituteInPlace configure --replace 'PREFIX=/usr' 'PREFIX=$out'
    ./configure
    make
    make install
  '';

  preFixup = ''
    substituteInPlace "$out/bin/backintime" \
      --replace "=\"/usr/share" "=\"$prefix/share"

    patchPythonScript $out/share/backintime/common/*.py

    substituteInPlace $out/bin/backintime \
      --replace 'python3 ' '${python3Packages.python.interpreter} '

    wrapProgram "$out/bin/backintime" \
      --prefix PYTHONPATH : "$PYTHONPATH"
    '';

  meta = with stdenv.lib; {
    description = "Simple backup tool for Linux";
    longDescription = ''
      Back In Time is a simple backup tool (on top of rsync) for Linux
      inspired from “flyback project” and “TimeVault”. The backup is
      done by taking snapshots of a specified set of directories.
    '';
    homepage    = https://github.com/bit-team/backintime;
    license     = licenses.gpl2;
    maintainers = [ peterhoeg ];
    platforms   = platforms.all;
  };
}
