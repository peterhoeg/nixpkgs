{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  babelfish,
  enzyme,
  pymediainfo,
  pyyaml,
  trakit,
  pint,
}:

buildPythonPackage rec {
  pname = "knowit";
  version = "0.5.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ratoaq2";
    repo = "knowit";
    tag = version;
    hash = "sha256-JqzCLdXEWZyvqXpeTJRW0zhY+wVcHLuBYrJbuSqfgkg=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    babelfish
    enzyme
    pymediainfo
    pyyaml
    trakit
  ];

  optional-dependencies = {
    pint = [
      pint
    ];
  };

  pythonImportsCheck = [
    "knowit"
  ];

  meta = {
    changelog = "https://github.com/ratoaq2/knowit/releases/tag/0.5.11";
    description = "Extract metadata from media files";
    homepage = "https://github.com/ratoaq2/knowit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ iynaix ];
    mainProgram = "knowit";
  };
}
