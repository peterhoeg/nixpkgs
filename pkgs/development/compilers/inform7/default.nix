{ lib, stdenv, fetchzip, perlPackages }:

let
  arch = {
    x86_64-linux = "x86_64";
    i686-linux = "i386";
  }.${stdenv.hostPlatform.system};

in
perlPackages.buildPerlPackage rec {
  pname = "inform7";
  version = "6M62";

  src = fetchzip {
    url = "http://inform7.com/download/content/${version}/I7_${version}_Linux_all.tar.gz";
    sha256 = "0bk0pfymvsn1g8ci0pfdw7dgrlzb232a8pc67y2xk6zgpf3m41vj";
  };

  outputs = [ "out" ];

  postPatch = "touch Makefile.PL";

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    for f in inform7-*_{all,${arch}}.tar.gz; do
      tar xzf $f --directory=$out
    done

    substituteInPlace $out/bin/i7 \
      --replace /usr/local $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "A design system for interactive fiction";
    homepage = "http://inform7.com/";
    license = licenses.artistic2;
    maintainers = with maintainers; [ mbbx6spp ];
    platforms = platforms.unix;
  };
}
