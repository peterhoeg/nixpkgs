{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  libnotify,
}:

python3Packages.buildPythonApplication rec {
  pname = "gcalcli";
  version = "4.5.1.20250427";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "insanum";
    repo = "gcalcli";
    rev = "91db693ab6cef28a62158bbf07091d10a72e63f4";
    hash = "sha256-HTVLjg9icv98IfLleP/Csq3bbe1DKNEpFiqlrwkriQ0=";
  };

  updateScript = nix-update-script { };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace gcalcli/argparsers.py \
      --replace-fail "'notify-send" "'${lib.getExe libnotify}"
  '';

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    argcomplete
    babel
    gflags
    google-api-python-client
    google-auth-oauthlib
    httplib2
    libnotify
    parsedatetime
    platformdirs
    pydantic
    python-dateutil
    truststore
    uritemplate
    vobject
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "CLI for Google Calendar";
    mainProgram = "gcalcli";
    homepage = "https://github.com/insanum/gcalcli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nocoolnametom ];
  };
}
