{ lib, fetchFromGitHub, crystal, makeBinaryWrapper, nix-prefetch-git }:

crystal.buildCrystalPackage rec {
  pname = "crystal2nix";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "crystal2nix";
    rev = "v${version}";
    sha256 = "sha256-gb2vgKWVXwYWfUUcFvOLFF0qB4CTBekEllpyKduU1Mo=";
  };

  format = "shards";

  nativeBuildInputs = [ makeBinaryWrapper ];

  postInstall = ''
    wrapProgram $out/bin/crystal2nix \
      --prefix PATH : ${lib.makeBinPath [ nix-prefetch-git ]}
  '';

  meta = with lib; {
    description = "Utility to convert Crystal's shard.lock files to a Nix file";
    license = licenses.mit;
    maintainers = with maintainers; [ manveru peterhoeg ];
  };
}
