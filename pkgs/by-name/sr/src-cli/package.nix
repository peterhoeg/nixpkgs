{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
  xorg,
  testers,
  src-cli,
}:

buildGoModule rec {
  pname = "src-cli";
  version = "6.6.0";

  src = fetchFromGitHub {
    owner = "sourcegraph";
    repo = "src-cli";
    rev = version;
    hash = "sha256-9jqlbqZ62wds+VOt5OT9XYu/v6ETaYGCqY7qJu3UsWg=";
  };

  vendorHash = "sha256-bpfDnVqJoJi9WhlA6TDWAhBRkbbQn1BHfnLJ8BTmhGM=";

  subPackages = [
    "cmd/src"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/sourcegraph/src-cli/internal/version.BuildTag=${version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = src-cli;
      command = "src version -client-only";
    };
  };

  meta = with lib; {
    description = "Sourcegraph CLI";
    homepage = "https://github.com/sourcegraph/src-cli";
    changelog = "https://github.com/sourcegraph/src-cli/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [
      figsoda
      keegancsmith
    ];
    mainProgram = "src";
  };
}
