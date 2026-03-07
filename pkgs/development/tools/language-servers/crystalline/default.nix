{
  lib,
  crystal,
  fetchFromGitHub,
  llvmPackages,
  openssl,
  shards,
  makeWrapper,
  _experimental-update-script-combinators,
  crystal2nix,
  runCommand,
  writeShellScript,
  gitUpdater,
  testers,
  crystalline,
}:

let
  version = "0.17.1";

in
crystal.buildCrystalPackage rec {
  pname = "crystalline";
  inherit version;

  src = fetchFromGitHub {
    owner = "elbywan";
    repo = "crystalline";
    rev = "v${version}";
    hash = "sha256-SIfInDY6KhEwEPZckgobOrpKXBDDd0KhQt/IjdGBhWo=";
  };

  format = "crystal";
  shardsFile = ./shards.nix;

  nativeBuildInputs = [
    llvmPackages.llvm
    openssl
    makeWrapper
    shards
  ];

  # for some reason just using env.LLVM_CONFIG isn't enough for the builder to find it, so export it manually early
  preBuild = ''
    export LLVM_CONFIG=${env.LLVM_CONFIG}
  '';

  env.LLVM_CONFIG = lib.getExe' (lib.getDev llvmPackages.llvm) "llvm-config";

  doCheck = false;
  doInstallCheck = false;

  crystalBinaries.crystalline = {
    src = "src/crystalline.cr";
    options = [
      "--release"
      "--no-debug"
      "--progress"
      "-Dpreview_mt"
    ];
  };

  postInstall = ''
    wrapProgram "$out/bin/${meta.mainProgram}" --prefix PATH : '${
      lib.makeBinPath [
        (lib.getDev llvmPackages.llvm)
      ]
    }'
  '';

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { rev-prefix = "v"; })
      (_experimental-update-script-combinators.copyAttrOutputToFile "crystalline.shardLock" "${builtins.toString ./.}/shard.lock")
      {
        command = [
          (writeShellScript "update-lock" "cd $1; ${lib.getExe crystal2nix}")
          ./.
        ];
        supportedFeatures = [ "silent" ];
      }
      {
        command = [
          "rm"
          "${builtins.toString ./.}/shard.lock"
        ];
        supportedFeatures = [ "silent" ];
      }
    ];
    shardLock = runCommand "shard.lock" { inherit src; } ''
      cp $src/shard.lock $out
    '';

    # Since doInstallCheck causes another test error, versionCheckHook is avoided.
    tests.version = testers.testVersion {
      package = crystalline;
    };
  };

  meta = {
    description = "Language Server Protocol implementation for Crystal";
    mainProgram = "crystalline";
    homepage = "https://github.com/elbywan/crystalline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ donovanglover ];
  };
}
