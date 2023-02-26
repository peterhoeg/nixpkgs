{ lib
, buildPythonPackage
, fetchFromGitHub
, pyperclip
, setuptools
, urwid
}:

buildPythonPackage rec {
  pname = "upass";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Kwpolska";
    repo = "upass";
    rev = "v${version}";
    sha256 = "sha256-IlNqPmDaRZ3yRV8O6YKjQkZ3fKNcFgzJHtIX0ADrOyU=";
  };

  propagatedBuildInputs = [
    pyperclip
    setuptools # needed for pkg_resources at runtime
    urwid
  ];

  # Project has no tests
  doCheck = false;

  postInstall = ''
    install -Dm444 -t $out/share/doc/${pname} *.rst

    # we need the .config directory to exist for the import check to work
    export HOME=$(mktemp -d)
    mkdir $HOME/.config
  '';

  pythonImportsCheck = [ "upass" ];

  meta = with lib; {
    description = "Console UI for pass";
    homepage = "https://github.com/Kwpolska/upass";
    license = licenses.bsd3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
