{
  lib,
  rustPlatform,
  fetchFromGitLab,
  installShellFiles,
  pam,
  nixosTests,
}:

rustPlatform.buildRustPackage rec {
  pname = "please";
  version = "0.5.5";

  src = fetchFromGitLab {
    owner = "edneville";
    repo = "please";
    rev = "v${version}";
    hash = "sha256-bQ91uCDA2HKuiBmHZ9QP4V6tM6c7hRvECqXzfC6EEnI=";
  };

  cargoHash = "sha256-iKRLq2G0XYZFM/k0V6GVtx/Pl4rdfGaD4EVN34FLlOg=";

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ pam ];

  patches = [ ./nixos-specific.patch ];

  postInstall = ''
    installManPage man/*
  '';

  # Unit tests are broken on NixOS.
  doCheck = false;

  passthru.tests = { inherit (nixosTests) please; };

  meta = with lib; {
    description = "Polite regex-first sudo alternative";
    longDescription = ''
      Delegate accurate least privilege access with ease. Express easily with a
      regex and expose only what is needed and nothing more. Or validate file
      edits with pleaseedit.

      Please is written with memory safe rust. Traditional C memory unsafety is
      avoided, logic problems may exist but this codebase is relatively small.
    '';
    homepage = "https://www.usenix.org.uk/content/please.html";
    changelog = "https://github.com/edneville/please/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
