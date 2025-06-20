{
  lib,
  python312Packages,
  fetchFromGitHub,
}:

let
  pypkgs = python312Packages;

in
pypkgs.buildPythonApplication rec {
  pname = "ffsubsync";
  version = "0.4.29";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "smacke";
    repo = "ffsubsync";
    tag = version;
    hash = "sha256-XMFobdr/nzr5pXjz/jWa/Pp14ITdbxAce0Iz+5qcBO4=";
  };

  build-system = with pypkgs; [ setuptools ];

  dependencies = with pypkgs; [
    auditok
    charset-normalizer
    faust-cchardet
    ffmpeg-python
    future
    numpy
    pkgs.ffmpeg
    pysubs2
    chardet
    rich
    setuptools
    six
    srt
    tqdm
    typing-extensions
    webrtcvad
  ];

  nativeCheckInputs = with pypkgs; [ pytestCheckHook ];

  pythonImportsCheck = [ "ffsubsync" ];

  meta = {
    homepage = "https://github.com/smacke/ffsubsync";
    description = "Automagically synchronize subtitles with video";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "ffsubsync";
  };
}
