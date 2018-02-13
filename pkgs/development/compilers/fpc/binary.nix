{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "fpc-${version}-binary";
  version = "3.0.4";

  src =
    if stdenv.system == "i686-linux" then
      fetchurl {
        url = "mirror://sourceforge/project/freepascal/Linux/${version}/fpc-${version}.i386-linux.tar";
        sha256 = "11yklvrfxvk59bxsd4rh1i6s3cjn0q06dzjs94h9fbq3n1qd5zdf";
      }
    else if stdenv.system == "x86_64-linux" then
      fetchurl {
        url = "mirror://sourceforge/project/freepascal/Linux/${version}/fpc-${version}.x86_64-linux.tar";
        sha256 = "0xzxh689iyjfmkqkhcqg9plrjmdx82hbyywyyc7jm0n92fpmp5ky";
      }

    else throw "Not supported on ${stdenv.system}.";

  builder = ./binary-builder.sh;

  meta = {
    description = "Free Pascal Compiler from a binary distribution";
  };
}
