{ stdenv, lib, buildGoPackage, fetchFromGitHub, terraform, makeWrapper }:

buildGoPackage rec {
  name = "terragrunt-${version}";
  version = "0.12.20";

  goPackagePath = "github.com/gruntwork-io/terragrunt";

  src = fetchFromGitHub {
    rev    = "v${version}";
    owner  = "gruntwork-io";
    repo   = "terragrunt";
    sha256 = "1jj6if5pb23ai5w6hg36sqggns0cyv6gavxn5k9aj93mhzdmg7f3";
  };

  goDeps = ./deps.nix;

  buildInputs = [ makeWrapper ];

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-X main.VERSION=v${version}")
  '';

  postInstall = ''
    wrapProgram $bin/bin/terragrunt \
      --set TERRAGRUNT_TFPATH ${lib.getBin terraform}/bin/terraform
  '';

  meta = with stdenv.lib; {
    description = "A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices.";
    homepage = https://github.com/gruntwork-io/terragrunt/;
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
