{ lib, fetchurl, mercurial, python2Packages
, qtsvg }:

python2Packages.buildPythonApplication rec {
    name = "tortoisehg-${version}";
    version = "4.5.3";

    src = fetchurl {
      url = "https://bitbucket.org/tortoisehg/targz/downloads/${name}.tar.gz";
      sha256 = "1lfv3v9a0azdgixspacqamdv0fmf4d7cvh796i6qiv9qnc65xj97";
    };

    pythonPath = with python2Packages; [ pyqt5 mercurial qscintilla-qt5 iniparse ];

    buildInputs = [ qtsvg ];

    propagatedBuildInputs = with python2Packages; [ qscintilla iniparse ];

    doCheck = false; # tests fail with "thg: cannot connect to X server"
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      ${python2Packages.python.executable} setup.py install --prefix=$out
      install -Dm644 -t $out/share/doc/tortoisehg COPYING.txt
      ln -s $out/bin/thg $out/bin/tortoisehg     #convenient alias

      runHook postInstall
    '';

    checkPhase = ''
      echo "test: thg version"
      $out/bin/thg version
    '';

    meta = with lib; {
      description = "Qt based graphical tool for working with Mercurial";
      homepage = http://tortoisehg.bitbucket.org/;
      license = licenses.gpl2;
      maintainers = with maintainers; [ danbst ];
      platforms = platforms.linux;
    };
}
