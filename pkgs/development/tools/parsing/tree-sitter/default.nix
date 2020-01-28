{ lib, stdenv
, fetchgit, fetchFromGitHub, fetchurl
, writeShellScript, runCommand
, rustPlatform, jq, nix-prefetch-git, xe, curl
}:

# TODO: move to carnix or https://github.com/kolloch/crate2nix
let
  # to update:
  # 1) change all these hashes
  # 2) nix-build -A tree-sitter.updater.update-all-grammars
  # 3) run the script that is output by that (it updates ./grammars)
  version = "0.16.3";
  sha256 = "12vpgn9b3mzcsl6f7fy09hdxm8xwzsca3wfc099zx4jkw9s2zpgf";
  sha256Js = "11114cc2m85siyhafh4hq9sjb5if4gfwsf9k87izkxpiyflda0wp"; # FIXME
  sha256Wasm = "1111bvjri8ivhah3sy22mx6jbvibgbn2hk67d148j3nyka3y4gc0"; # FIXME
  cargoSha256 = "0cvwrii9mhi2ixsp7yhffcl402760zwh32clww6m81qmf0skin00";


  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter";
    rev = version;
    inherit sha256;
    fetchSubmodules = true;
  };

  fetchDist = {file, sha256}: fetchurl {
    url = "https://github.com/tree-sitter/tree-sitter/releases/download/${version}/${file}";
    inherit sha256;
  };

  # TODO: not distributed anymore; needed for the web-ui module,
  # see also the disable-web-ui patch.
  # TODO: build those instead of downloading prebuilt
  # js = fetchDist {
  #   file = "tree-sitter.js";
  #   sha256 = sha256Js;
  # };
  # wasm = fetchDist {
  #   file = "tree-sitter.wasm";
  #   sha256 = sha256Wasm;
  # };

  update-all-grammars = import ./update.nix {
    inherit writeShellScript nix-prefetch-git curl jq xe src;
  };

  grammars =
    let fetch =
      (v: fetchgit {inherit (v) url rev sha256 fetchSubmodules; });
    in runCommand "grammars" {} (''
       mkdir $out
     '' + (lib.concatStrings (lib.mapAttrsToList
            (name: grammar: "ln -s ${fetch grammar} $out/${name}\n")
            (import ./grammars))));


in rustPlatform.buildRustPackage {
  pname = "tree-sitter";
  inherit version;
  inherit src;

  patches = [
    # the web ui requires tree-sitter compiled to js and wasm
    ./disable-web-ui.patch
  ];

  postPatch = ''
    # needed for the tests
    rm -rf test/fixtures/grammars
    ln -s ${grammars} test/fixtures/grammars
  '';

  passthru = {
    updater = {
      inherit update-all-grammars;
    };
    inherit grammars;
  };

  inherit cargoSha256;

  meta = {
    homepage = "https://github.com/tree-sitter/tree-sitter";
    description = "A parser generator tool and an incremental parsing library";
    longDescription = ''
      Tree-sitter is a parser generator tool and an incremental parsing library.
      It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited.

      Tree-sitter aims to be:

      * General enough to parse any programming language
      * Fast enough to parse on every keystroke in a text editor
      * Robust enough to provide useful results even in the presence of syntax errors
      * Dependency-free so that the runtime library (which is written in pure C) can be embedded in any application
    '';
    platforms = lib.platforms.all;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Profpatsch ];
    # Darwin needs some more work with default libraries
    # Aarch has test failures with how tree-sitter compiles the generated C files
    broken = stdenv.isDarwin || stdenv.isAarch64;
  };

}
