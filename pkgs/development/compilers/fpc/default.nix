{ stdenv, fetchurl, gawk }:

let
  isx86Linux = (stdenv.system == "i686-linux" || stdenv.system == "x86_64-linux");
  startFPC = import ./binary.nix { inherit stdenv fetchurl; };

in stdenv.mkDerivation rec {
  version = "3.0.2";
  name = "fpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/freepascal/fpcbuild-${version}.tar.gz";
    # 3.0.0
    # sha256 = "1111bjp0kvsi8y0mndqvvhnsqjfssl2w6wpfww51j4rxblfkp4fm";
    # 3.0.2
    sha256 = "0x8vajb3brmh078hxz0pydym1wbxf1dxca7lzxlh268z6q5fsqgj";
    # 3.0.4
    # sha256 = "0xjyhlhz846jbnp12y68c7nq4xmp4i65akfbrjyf3r62ybk18rgn";
  };

  buildInputs = [ startFPC gawk ];

  # TODO: we need to substitute the paths here to crti.o
  preConfigure = stdenv.lib.optionalString isx86Linux ''
    sed -i fpcsrc/compiler/systems/t_linux.pas \
      -e "s@'/lib/ld-linux[^']*'@'''@" \
      -e "s@'/lib64/ld-linux[^']*'@'''@"
  '';

  makeFlags = "NOGDB=1 FPC=${startFPC}/bin/fpc";

  installFlags = "INSTALL_PREFIX=\${out}";

  postInstall = ''
    for i in $out/lib/fpc/*/ppc*; do
      ln -fs $i $out/bin/$(basename $i)
    done
    mkdir -p $out/lib/fpc/etc/
    $out/lib/fpc/*/samplecfg $out/lib/fpc/${version} $out/lib/fpc/etc/
  '';

  passthru = {
    bootstrap = startFPC;
  };

  meta = with stdenv.lib; {
    description = "Free Pascal Compiler from a source distribution";
    inherit (startFPC.meta) maintainers platforms;
    inherit version;
  };
}
