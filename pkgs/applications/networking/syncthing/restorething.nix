{ stdenv, lib, fetchFromGitHub, python2Packages, removeReferencesTo }:

with python2Packages;

buildPythonApplication rec {
  name = "restorething-${version}";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner  = "madmickstar";
    repo   = "restorething";
    rev    = "v${version}";
    sha256 = "1q9c5mfni8gg3iagmbw5ka96cp7bkk1vy8bvn1xmw21arz4zwz27";
  };

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${python.interpreter} $out/bin/restorething  \
      --argv0 restorething \
      --prefix PYTHONPATH : $out/${python.sitePackages} \
      --add-flags "-m restorething"
  '';

  doCheck = false; # no tests available

  meta = with stdenv.lib; {
    description = "Restore tool for syncthing ";
    homepage    = https://github.com/madmickstar/restorething;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
