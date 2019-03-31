{ stdenv, fetchurl }:

let
  system = stdenv.hostPlatform.system;

  generic = version: sha256s: stdenv.mkDerivation {
    name = "fpc-${version}-binary";

    src = if stdenv.hostPlatform.system == "i686-linux" then
      fetchurl {
        url = "mirror://sourceforge/project/freepascal/Linux/${version}/fpc-${version}.i386-linux.tar";
        sha256 = sha256s."${system}";
      }
    else if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "mirror://sourceforge/project/freepascal/Linux/${version}/fpc-${version}.x86_64-linux.tar";
        sha256 = sha256s."${system}";
      }
    else throw "Not supported on ${stdenv.hostPlatform.system}.";

    builder = ./binary-builder.sh;

    meta = {
      description = "Free Pascal Compiler from a binary distribution";
    };
  };

in {
  fpc-binary_260 = generic "2.6.0" {
    i686-linux   = "08yklvrfxvk59bxsd4rh1i6s3cjn0q06dzjs94h9fbq3n1qd5zdf";
    x86_64-linux = "0k9vi75k39y735fng4jc2vppdywp82j4qhzn7x4r6qjkad64d8lx";
  };

  fpc-binary_300 = generic "3.0.0" {
    i686-linux   = "11yklvrfxvk59bxsd4rh1i6s3cjn0q06dzjs94h9fbq3n1qd5zdf";
    x86_64-linux = "1m2xx3nda45cb3zidbjgdr8kddd19zk0khvp7xxdlclszkqscln9";
  };

  fpc-binary_304 = generic "3.0.4" {
    i686-linux   = "1111lvrfxvk59bxsd4rh1i6s3cjn0q06dzjs94h9fbq3n1qd5zdf";
    x86_64-linux = "0xzxh689iyjfmkqkhcqg9plrjmdx82hbyywyyc7jm0n92fpmp5ky";
  };
}
