{
  lib,
  rustPlatform,
  fetchFromGitHub,
  withJson ? true,
  stdenv,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "statix";
  # also update version of the vim plugin in
  # pkgs/applications/editors/vim/plugins/overrides.nix
  # the version can be found in flake.nix of the source code
  version = "0.5.8-unstable-2025-12-19";

  src = fetchFromGitHub {
    owner = "molybdenumsoftware";
    repo = "statix";
    rev = "83746932a76912ce7aca839f2a0358d46ed70fc9";
    hash = "sha256-qPWU0TpiEzF7Scl5S5tU754BzDyw52nNi04m+UTvW9Y=";
  };

  cargoHash = "sha256-G4OVh7Ese672gxiJdPE8D1J6p8OmiawG+mYSaVbIDR8=";

  buildFeatures = lib.optional withJson "json";

  # tests are failing on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  # doInstallCheck = true;
  # nativeInstallCheckInputs = [ versionCheckHook ];
  # versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lints and suggestions for the nix programming language";
    homepage = "https://github.com/oppiliappan/statix";
    license = lib.licenses.mit;
    mainProgram = "statix";
    maintainers = with lib.maintainers; [
      nerdypepper
      progrm_jarvis
    ];
  };
})
