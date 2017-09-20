{ stdenv, lib, fetchFromGitHub, fetchurl, git, makeWrapper
, boehmgc, libatomic_ops, pcre, libevent, libiconv, llvm_4 }:

let
  version = "0.23.1";
  # 0.23.1 crashes when doing a release build as it uses LLVM 3.8
  # https://github.com/crystal-lang/crystal/issues/4719
  binVersion = "0.23.0";
  binSuffix = "1";

  arch = {
    "x86_64-linux"  = "linux-x86_64";
    "i686-linux"    = "linux-i686";
    "x86_64-darwin" = "darwin-x86_64";
  }."${stdenv.system}" or (throw "system ${stdenv.system} not supported");

  binary = stdenv.mkDerivation rec {
    name = "crystal-binary-${binVersion}-${binSuffix}";

    src = fetchurl {
      url = "https://github.com/crystal-lang/crystal/releases/download/${binVersion}/crystal-${binVersion}-${binSuffix}-${arch}.tar.gz";
      sha256 = {
        "x86_64-linux"  = "0nhs7swbll8hrk15kmmywngkhij80x62axiskb1gjmiwvzhlh0qx";
        "i686-linux"    = "03xp8d3lqflzzm26lpdn4yavj87qzgd6xyrqxp2pn9ybwrq8fx8a";
        "x86_64-darwin" = "1prz6c1gs8z7dgpdy2id2mjn1c8f5p2bf9b39985bav448njbyjz";
      }."${stdenv.system}" or (throw "system ${stdenv.system} not supported");
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/opt
      cp -r * $out/opt
      mv $out/opt/bin $out
    '';

    preFixup = ''
      sed -i $out/bin/crystal \
        -e "s,^INSTALL_DIR=.*,INSTALL_DIR=$out/opt,"

      ${if stdenv.isDarwin then ''
        wrapProgram $out/opt/embedded/bin/crystal \
          --suffix DYLD_LIBRARY_PATH : $libPath
      '' else ''
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          --set-rpath       ${stdenv.lib.makeLibraryPath [ stdenv.cc.cc ]} \
          $out/opt/embedded/bin/crystal
      ''}
    '';
  };

in stdenv.mkDerivation rec {
  name = "crystal-${version}";

  src = fetchFromGitHub {
    owner  = "crystal-lang";
    repo   = "crystal";
    rev    = version;
    sha256 = "0ixqrkpf961l0w4qhm8r8v37smfq7xya4cnm8dss7hi4wc49svkk";
  };

  buildInputs = [
    boehmgc libatomic_ops pcre libevent llvm_4
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    libiconv
  ];

  nativeBuildInputs = [ binary makeWrapper ];

  libPath = stdenv.lib.makeLibraryPath ([
    boehmgc libatomic_ops pcre libevent
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    libiconv
  ]);

  makeFlags = [
    "crystal"
    "doc"
    "release=1"
    "progress=true"
  ];

  # I get OOM on an 8GB machine when running the tests
  doCheck = false;

  checkTarget = "spec";

  installPhase = ''
    install -Dm755 .build/crystal $out/bin/crystal
    wrapProgram $out/bin/crystal \
        --suffix CRYSTAL_PATH : $out/lib/crystal \
        --suffix LIBRARY_PATH : $libPath \
        --suffix PATH         : ${stdenv.lib.makeBinPath [ llvm_4 ]}

    install -dm755 $out/lib/crystal
    cp -r src/* $out/lib/crystal/

    install -dm755 $out/share/doc/crystal/api
    cp -r doc/* $out/share/doc/crystal/api/
    cp -r samples $out/share/doc/crystal/

    install -Dm644 etc/completion.bash $out/share/bash-completion/completions/crystal
    install -Dm644 etc/completion.zsh $out/share/zsh/site-functions/_crystal

    install -Dm644 man/crystal.1 $out/share/man/man1/crystal.1

    install -Dm644 LICENSE $out/share/licenses/crystal/LICENSE
  '';

  # dontStrip = true;

  meta = with stdenv.lib; {
    description = "A compiled language with Ruby like syntax and type inference";
    homepage    = https://crystal-lang.org/;
    license     = licenses.asl20;
    maintainers = with maintainers; [ mingchuan ];
    platforms   = [ "x86_64-linux" "i686-linux" "x86_64-darwin" ];
  };
}
