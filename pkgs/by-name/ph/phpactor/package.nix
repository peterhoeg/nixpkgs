{
  lib,
  fetchFromGitHub,
  installShellFiles,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "phpactor";
  version = "2024.06.30.0";

  src = fetchFromGitHub {
    owner = "phpactor";
    repo = "phpactor";
    rev = finalAttrs.version;
    hash = "sha256-QcKkkgpWWypapQPawK1hu+6tkF9c5ICPeEPWqCwrUBM=";
  };

  patches = [
    ./php-83-class-constants.patch
  ];

  vendorHash = "sha256-woTeQw1w7Po12WQVq54fE8fQLA3+ql6iufplukOrSIQ=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd phpactor \
    --bash <(php $out/bin/phpactor completion bash)
  '';

  meta = {
    changelog = "https://github.com/phpactor/phpactor/releases/tag/${finalAttrs.version}";
    description = "Mainly a PHP Language Server";
    homepage = "https://github.com/phpactor/phpactor";
    license = lib.licenses.mit;
    mainProgram = "phpactor";
    maintainers = lib.teams.php.members;
  };
})
