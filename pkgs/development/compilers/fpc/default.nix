{ stdenv, fetchurl, makeWrapper, writeText, binutils, gawk }:

let
  inherit (import ./binary.nix { inherit stdenv fetchurl; }) fpc-binary_260 fpc-binary_300 fpc-binary_304;

  helloWorld = writeText "hello.pas" ''
    program Hello;
    begin
      writeln('Hello, world.');
    end.
  '';

  generic = version: sha256: binary: stdenv.mkDerivation rec {
    name = "fpc-${version}";

    src = fetchurl {
      url = "mirror://sourceforge/freepascal/fpcbuild-${version}.tar.gz";
      inherit sha256;
    };

    buildInputs = [ binutils ];

    nativeBuildInputs = [ binary makeWrapper gawk ];

    # We were previously only doing this when building on Linux but we might as well do it all the time.
    # It shouldn't in any way interfere with building on other platforms.
    preConfigure = ''
      sed -i fpcsrc/compiler/systems/t_linux.pas \
        -e "s@'/lib/@'${stdenv.cc.libc}/lib/@"   \
        -e "s@'/lib64/@'${stdenv.cc.libc}/lib/@"
    '';

    makeFlags = [
      "NOGDB=1"
      "FPC=${binary}/bin/fpc"
      # "LD=${binutils}/bin/ld.gold"
      ''OPT="-gl"''
    ];

    installFlags = [
      "INSTALL_PREFIX=$(out)"
    ];

    # NIX_LDFLAGS = [
    #   "-rpath ${stdenv.cc.cc.lib}/lib"
    #   "-rpath ${stdenv.cc.libc}/lib"
    # ];

    postInstall = ''
      for i in $out/lib/fpc/*/ppc*; do
        ln -fs $i $out/bin/$(basename $i)
      done
      mkdir -p $out/lib/fpc/etc/
      $out/lib/fpc/*/samplecfg $out/lib/fpc/${version} $out/lib/fpc/etc/

      wrapProgram $out/bin/fpc \
        --prefix PATH : ${stdenv.lib.makeBinPath [ binutils ]}
    '';

    doInstallCheck = true;

    installCheckPhase = ''
      $out/bin/fpc -o./hello ${helloWorld}
      ./hello
    '';

    passthru = {
      bootstrap = binary;
    };

    meta = with stdenv.lib; {
      description = "Free Pascal Compiler from a source distribution";
      homepage = https://www.freepascal.org;
      maintainers = with maintainers; [ raskin ];
      license = with licenses; [ gpl2 lgpl2 ];
      platforms = platforms.linux;
      inherit version;
    };
  };

in rec {
  fpc_300 = generic "3.0.0" "1v40bjp0kvsi8y0mndqvvhnsqjfssl2w6wpfww51j4rxblfkp4fm" fpc-binary_304;
  fpc_302 = generic "3.0.2" "0x8vajb3brmh078hxz0pydym1wbxf1dxca7lzxlh268z6q5fsqgj" fpc-binary_304;
  fpc_304 = generic "3.0.4" "0xjyhlhz846jbnp12y68c7nq4xmp4i65akfbrjyf3r62ybk18rgn" fpc-binary_304;
  fpc = fpc_304;
}
