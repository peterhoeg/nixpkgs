{ stdenv, fetchurl, python2Packages, git }:

python2Packages.buildPythonApplication rec {
  version = "1.4.5";
  name = "git-up-${version}";

  src = fetchurl {
    url = "mirror://pypi/g/git-up/${name}.zip";
    sha256 = "153f8rvcr3a8n1h54aamg51fhlqszlhzpllb3gmrgpxpbj2d2mqb";
  };

  buildInputs = [ git ] ++ (with python2Packages; [ nose ]);
  propagatedBuildInputs = with python2Packages; [ click colorama docopt GitPython six termcolor ];

  # 1. git fails to run as it cannot detect the email address, so we set it
  # 2. $HOME is by default not a valid dir, so we have to set that too
  # https://github.com/NixOS/nixpkgs/issues/12591
  preCheck = ''
      export HOME=$TMPDIR
      git config --global user.email "nobody@example.com"
      git config --global user.name "Nobody"
    '';

  postInstall = ''
    rm -r $out/${python2Packages.python.sitePackages}/PyGitUp/tests
  '';

  meta = with stdenv.lib; {
    homepage = http://github.com/msiemens/PyGitUp;
    description = "A git pull replacement that rebases all local branches when pulling.";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.all;
  };
}
