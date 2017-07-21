{ stdenv, fetchurl, binutils, gawk, makeWrapper }:

let
  startFPC = import ./binary.nix { inherit stdenv fetchurl; };

in stdenv.mkDerivation rec {
  version = "3.0.2";
  name = "fpc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/freepascal/fpcbuild-${version}.tar.gz";
    sha256 = "0x8vajb3brmh078hxz0pydym1wbxf1dxca7lzxlh268z6q5fsqgj";
  };

  buildInputs = [ stdenv.cc ];
  nativeBuildInputs = [ gawk makeWrapper startFPC ];

  configurePhase = ''
    runHook preConfigure

    ${stdenv.lib.optionalString stdenv.isLinux ''
    substituteInPlace fpcsrc/compiler/systems/t_linux.pas \
      --replace "'/lib/ld-linux"   "'${stdenv.cc.libc}/lib/ld-linux" \
      --replace "'/lib64/ld-linux" "'${stdenv.cc.libc}/lib/ld-linux"
    ''}

    fpcmake -w

    runHook postConfigure
  '';

  makeFlags = [
    "FPC=${startFPC}/bin/fpc"
    "NOGDB=1"
    "OPT=-Fl${stdenv.cc.libc}/lib"
    "RELEASE=1"
    "build"
  ];

  installFlags = [
    "INSTALL_PREFIX=\${out}"
  ];

#     cat <<_EOF >>$out/lib/fpc/etc/fpc.cfg
# # added by nixpkgs:
# -Fl${stdenv.glibc.out}/lib
# _EOF

  postInstall = ''
    for i in $out/lib/fpc/*/ppc*; do
      ln -fs $i $out/bin/$(basename $i)
    done
    mkdir -p $out/lib/fpc/etc/
    $out/lib/fpc/*/samplecfg $out/lib/fpc/${version} $out/lib/fpc/etc/
    substituteInPlace $out/lib/fpc/etc/fpc.cfg \
      --replace '-l' '# -l'
  '';

  postFixup = ''
    wrapProgram $out/bin/fpc \
      --prefix PATH : "$out/bin:${stdenv.lib.makeBinPath [ binutils ]}"
  '';


  doInstallCheck = true;

  installCheckPhase = ''
    echo "program Hello; begin writeln ('Hello, world!') end." > hello.pas
    $out/bin/fpc hello.pas
    ./hello
  '';

  passthru = {
    bootstrap = startFPC;
  };

  meta = with stdenv.lib; {
    description = "Free Pascal Compiler from a source distribution";
    maintainers = with maintainers; [ raskin ];
    inherit (startFPC.meta) platforms;
    inherit version;
  };
}
