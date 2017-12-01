{ stdenv, fetchFromGitHub, fetchpatch, bundler, bundix, git
, dpkg, curl, libarchive, openssl, rake, ruby, buildRubyGem, libiconv
, libxml2, libxslt, libffi, makeWrapper, p7zip, xar, gzip, cpio }:

stdenv.mkDerivation rec {
  name = "vagrant-${version}";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "vagrant";
    rev = "v${version}";
    sha256 = "1fzqn4z1qyri4vxmvdq4cs2rzsj8j8k77sdhrl1qxas9brmvad76";
  };

  meta = with stdenv.lib; {
    description = "A tool for building complete development environments";
    homepage    = http://vagrantup.com;
    license     = licenses.mit;
    maintainers = with maintainers; [ lovek323 globin jgeerds kamilchm ];
    platforms   = with platforms; linux ++ darwin;
  };

  buildInputs = [ bundler bundix ];

  nativeBuildInputs = [ git makeWrapper ];

  buildPhase = ''
    runHook preInstall

    export HOME=$TMP

    bundle install

    runHook postInstall
  '';

}
