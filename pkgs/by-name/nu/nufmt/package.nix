{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "nufmt";
  version = "0-unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "nushell";
    repo = "nufmt";
    rev = "c7eda5911c1e332c2b6c6bb3018454b590b91fbe";
    hash = "sha256-8/J/qJn7HJ9XNkVWh9rv3j742yy38Sj87xbnBNjvMd4=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-0vfOl+niIw9dma9u6460xGR5thcnwKKSKNhzzj9JstU=";

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Nushell formatter";
    homepage = "https://github.com/nushell/nufmt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      khaneliman
    ];
    mainProgram = "nufmt";
  };
}
