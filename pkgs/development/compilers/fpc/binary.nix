{ stdenv, fetchurl }:

let
  version = "3.0.4";

  arch = {
    "x86_64-linux" = "x86_64-linux";
    "i686-linux"   = "i386-linux";
  }.${stdenv.system};

  sha256 = {
    # 2.6.4
    # "x86_64-linux" = "0f9vvafjyg3pmb9hw7r62hfqjcwin9hlzj5lgx22qxvxj9pkhv0r";
    "x86_64-linux" = "0xzxh689iyjfmkqkhcqg9plrjmdx82hbyywyyc7jm0n92fpmp5ky";
    "i686-linux"   = "111klvrfxvk59bxsd4rh1i6s3cjn0q06dzjs94h9fbq3n1qd5zdf";
  }.${stdenv.system};

in stdenv.mkDerivation {
  name = "fpc-binary-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/project/freepascal/Linux/${version}/fpc-${version}.${arch}.tar";
    inherit sha256;
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    tarballdir=$(pwd)
    for i in *.tar; do tar xvf $i; done
    echo "Deploying binaries..."
    for i in $tarballdir/*.gz; do tar --directory=$out -xvf $i; done
    echo 'Creating ppc* symlink...'
    for i in $out/lib/fpc/*/ppc*; do
      ln -fs $i $out/bin/$(basename $i)
    done

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Free Pascal Compiler from a binary distribution";
    maintainers = with maintainers; [ raskin peterhoeg ];
    platforms = [ "x86_64-linux" "i686-linux" ];
    inherit version;
  };
}
