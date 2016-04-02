{ stdenv, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation rec {
  name = "rbenv-${version}";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "rbenv";
    repo = "rbenv";
    rev = "v${version}";
    sha256 = "1c51q5pxnfmg33ylqw0s2jvk7n2ipqqja5dzxv91m5b2y85xm56z";
  };

  buildInputs = [ makeWrapper ];

  # dontStrip = true;

  installPhase = ''
    mkdir -p \
      $out/bin \
      $out/lib/{completions,libexec} \
      $out/lib/hooks/exec/gem-rehash \
      $out/share/doc

    install -m644 ./LICENSE       $out/share/doc/LICENSE
    install -m644 ./completions/* $out/lib/completions/
    install -m755 ./libexec/*     $out/lib/libexec/
    ln -s --relative $out/libexec/rbenv $out/bin/rbenv

    install -m644 rbenv.d/exec/gem-rehash/rubygems_plugin.rb \
      $out/lib/hooks/exec/gem-rehash/rubygems_plugin.rb
    install -m644 rbenv.d/exec/gem-rehash.bash \
      $out/lib/hooks/exec/gem-rehash.bash

    wrapProgram $out/bin/rbenv
  '';

  meta = {
    homepage = https://github.com/rbenv/rbenv;
    license = stdenv.lib.licenses.free;
    description = "Build rubies with ease";
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.peterhoeg ];
  };
}
