{ stdenv, fetchurl, gawk }:

let
  startFPC = import ./binary.nix { inherit stdenv fetchurl; };

in stdenv.mkDerivation rec {
  name = "fpc-${version}";
  version = "3.0.4";

  src = fetchurl {
    url = "mirror://sourceforge/freepascal/fpcbuild-${version}.tar.gz";
    sha256 = "0xjyhlhz846jbnp12y68c7nq4xmp4i65akfbrjyf3r62ybk18rgn";
  };

  buildInputs = [ startFPC gawk ];

  preConfigure =
    if stdenv.system == "i686-linux" || stdenv.system == "x86_64-linux" then ''
      linker=$(gcc -print-file-name=ld-linux-x86-64.so.2)
      sed -i fpcsrc/compiler/systems/t_linux.pas \
        -e "s@'/lib/ld-linux[^']*'@'$linker'@" \
        -e "s@'/lib64/ld-linux[^']*'@'$linker'@"
    '' else "";

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
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
    inherit version;
  };
}
