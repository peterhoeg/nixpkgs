{ lib, fetchFromGitHub, crystal, makeWrapper }:

crystal.buildCrystalPackage rec {
  pname = "lucky-cli";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "luckyframework";
    repo = "lucky_cli";
    rev = "v${version}";
    sha256 = "0j5igx1yq6xpxkyhb8vqhzmgy4r4b47iplyvvgcnlksj3h67rxaz";
  };

  lockFile = ./shard.lock;
  shardsFile = ./shards.nix;

  crystalBinaries.lucky.src = "src/lucky.cr";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    install -Dm444 README.md -t $out/share/doc/${pname}

    wrapProgram $out/bin/lucky \
      --prefix PATH : ${lib.makeBinPath [ crystal ]}
  '';

  meta = with lib; {
    description = "A Crystal library for creating and running tasks. Also generates Lucky projects";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
