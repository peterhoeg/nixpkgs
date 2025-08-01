{
  lib,
  stdenv,
  altair,
  blinker,
  buildPythonPackage,
  cachetools,
  click,
  fetchPypi,
  gitpython,
  numpy,
  packaging,
  pandas,
  pillow,
  protobuf,
  pyarrow,
  pydeck,
  pythonOlder,
  setuptools,
  requests,
  rich,
  tenacity,
  toml,
  tornado,
  typing-extensions,
  watchdog,
}:

buildPythonPackage rec {
  pname = "streamlit";
  version = "1.46.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Cyc0tI8R8eXIBGARtrGiJ0mC3GV+7yrejbcPDh3FPdo=";
  };

  build-system = [
    setuptools
  ];

  pythonRelaxDeps = [ "packaging" ];

  dependencies = [
    altair
    blinker
    cachetools
    click
    numpy
    packaging
    pandas
    pillow
    protobuf
    pyarrow
    requests
    rich
    tenacity
    toml
    typing-extensions
    gitpython
    pydeck
    tornado
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ watchdog ];

  # pypi package does not include the tests, but cannot be built with fetchFromGitHub
  doCheck = false;

  pythonImportsCheck = [ "streamlit" ];

  postInstall = ''
    rm $out/bin/streamlit.cmd # remove windows helper
  '';

  meta = with lib; {
    homepage = "https://streamlit.io/";
    changelog = "https://github.com/streamlit/streamlit/releases/tag/${version}";
    description = "Fastest way to build custom ML tools";
    mainProgram = "streamlit";
    maintainers = with maintainers; [
      natsukium
      yrashk
    ];
    license = licenses.asl20;
  };
}
