{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
  rust-jemalloc-sys,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "difftastic";
  version = "0.69.0";

  src = fetchFromGitHub {
    owner = "wilfred";
    repo = "difftastic";
    tag = finalAttrs.version;
    hash = "sha256-86aA9B/AaLKhHbaBKL6XpcqocghijCoxyrWUE5YOdaA=";
  };

  cargoHash = "sha256-by/gl6qI6mc93Kxn0BdIhkL/gtoHcGwdzrGiT5KTmP4=";

  buildInputs = [ rust-jemalloc-sys ];

  env = lib.optionalAttrs stdenv.hostPlatform.isStatic { RUSTFLAGS = "-C relocation-model=static"; };

  postInstall = ''
    installManPage difft.?
    install -Dm444 -t $out/share/doc/difftastic *.md
  '';

  # skip flaky tests
  checkFlags = [ "--skip=options::tests::test_detect_display_width" ];

  nativeInstallCheckInputs = [
    installShellFiles
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Syntax-aware diff";
    homepage = "https://github.com/Wilfred/difftastic";
    changelog = "https://github.com/Wilfred/difftastic/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      ethancedwards8
      matthiasbeyer
      defelo
    ];
    mainProgram = "difft";
  };
})
