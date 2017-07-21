{ stdenv, fetchurl }:

let
  sha256 = {
    "x86_64-linux" = "1n1b92j8n0gbp6gc2a9bar830255v29c3wwqm2v0a78vqgdpzcmm";
    "i686-linux"   = "1vzm7xjgmsg76pcmkh0vmb5a482qw4wf32l1pmwmd2y3lwkhmnrd";
  }."${stdenv.system}" or (throw "system ${stdenv.system} not supported");

  arch = {
    "x86_64-linux" = "x86_64";
    "i686-linux"   = "i386";
  }."${stdenv.system}" or (throw "system ${stdenv.system} not supported");

in stdenv.mkDerivation rec {
  name = "fpc-${version}-binary";
  version = "3.0.2";

  src = fetchurl {
    url = "mirror://sourceforge/project/freepascal/Linux/${version}/fpc-${version}.${arch}-linux.tar";
    inherit sha256;
  };

  builder = ./binary-builder.sh;

  meta = with stdenv.lib; {
    description = "Free Pascal Compiler from a binary distribution";
    platforms = platforms.linux;
    inherit version;
  };
}
