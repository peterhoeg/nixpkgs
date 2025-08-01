{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "teehee";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "Gskartwii";
    repo = "teehee";
    rev = "v${version}";
    hash = "sha256-yTterXAev6eOnUe1/MJV8s8dUYJcXHDKVJ6T0G/JHzI=";
  };

  cargoHash = "sha256-PebwLIFBA6NdEXCQoEZzPFsSTMz8o2s+yOMyElrR4TM=";

  meta = with lib; {
    description = "Modal terminal hex editor";
    homepage = "https://github.com/Gskartwii/teehee";
    changelog = "https://github.com/Gskartwii/teehee/releases/tag/${src.rev}";
    license = licenses.asl20;
    maintainers = with maintainers; [ figsoda ];
    mainProgram = "teehee";
  };
}
