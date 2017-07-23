{ stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "thefuck-${version}";
  version = "3.18";

  src = fetchFromGitHub {
    owner  = "nvbn";
    repo   = "thefuck";
    rev    = version;
    sha256 = "14fg5faip6s4j9c7799bkswc6j5hb5npcg8nwrjjfdgr05jp7389";
  };

  propagatedBuildInputs = with python3Packages; [
    colorama decorator pathlib2 psutil six
  ];

  checkInputs = with python3Packages; [ mock pytest pytest-mock tox ];

  # prePatch = ''
  #   for f in thefuck/shells/*.py ; do
  #     substituteInPlace $f --replace thefuck $out/bin/thefuck
  #   done

  #   for f in tests/shells/test_*.py ; do
  #     substituteInPlace $f --replace '$(thefuck' "\$($out/bin/thefuck"
  #   done
  # '';

  checkPhase = ''
    export PYTHONIOENCODING=utf8
    export LANG="en_US.UTF-8"
    py.test --capture=sys
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/nvbn/thefuck;
    description = "Magnificent app which corrects your previous console command.";
    license = licenses.mit;
    maintainers = with maintainers; [ ma27 ];
  };
}
