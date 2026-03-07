{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  libnotify,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gcalcli";
  version = "4.5.1-unstable-2025-10-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "insanum";
    repo = "gcalcli";
    rev = "405639c27639a82a13538ad72ae012e76942530c";
    hash = "sha256-TGaWSRZ/lNQTnxs/0WQ+DnrzmgaNSY5iEtSqHKqnDPU=";
  };

  env.SETUPTOOLS_SCM_PRETEND_VERSION = lib.splitString "-" finalAttrs.version |> builtins.head;

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
})
