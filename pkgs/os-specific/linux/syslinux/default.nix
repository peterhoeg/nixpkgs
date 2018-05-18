{ stdenv, lib, fetchFromGitHub, fetchurl, nasm, perl, python, libuuid, mtools, makeWrapper }:

let
  gnu-efi = stdenv.mkDerivation rec {
    name = "gnu-efi-${version}";
    version = "3.0.3";

    src = fetchurl {
      url = "mirror://sourceforge/gnu-efi/${name}.tar.bz2";
      sha256 = "1jxlypkgb8bd1c114x96i699ib0glb5aca9dv56j377x2ldg4c65";
    };

    postPatch = ''
      substituteInPlace Make.defaults \
        --replace /usr/bin/  "" \
        --replace /usr/local $out
    '';

    # Fixed in 3.0.6 onwards
    NIX_CFLAGS_COMPILE = lib.optionalString (lib.versionOlder version "3.0.6") "-Wimplicit-fallthrough=0";

    enableParallelBuilding = true;
  };

in stdenv.mkDerivation rec {
  name = "syslinux-${version}";
  version = "6.03.20171123";

  src = fetchFromGitHub {
    owner  = "geneC";
    repo   = "syslinux";
    rev    = "2ea44cbedb297bd6b409d5c1e0402d5f89592be4";
    sha256 = "1rb1gngr67r401w59zj1z2w850cwn4w0lb5pdxayz7kbvnx5bvv9";
    # fetchSubmodules = true;
  };

  patches = [
    # ./perl-deps.patch
  #   (fetchurl {
  #     # ldlinux.elf: Not enough room for program headers, try linking with -N
  #     name = "not-enough-room.patch";
  #          url = "https://anonscm.debian.org/cgit/collab-maint/syslinux.git/plain/"
  #         + "debian/patches/0014_fix_ftbfs_no_dynamic_linker.patch?id=a556ad7";
  #     sha256 = "0ijqjsjmnphmvsx0z6ppnajsfv6xh6crshy44i2a5klxw4nlvrsw";
  #   })
  ];

  nativeBuildInputs = [ nasm perl python ];
  buildInputs = [ gnu-efi libuuid makeWrapper ];

  enableParallelBuilding = false; # Fails very rarely with 'No rule to make target: ...'
  hardeningDisable = [ "pic" "stackprotector" "fortify" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /bin/pwd $(type -P pwd)

    substituteInPlace utils/ppmtolss16 \
      --replace /usr/bin/perl $(type -P perl)

    substituteInPlace mk/efi.mk \
      --replace '$(objdir)' ${gnu-efi}

    # sed -e '/VPrint/,+8d' -i efi/fio.h

    # disable debug and development flags to reduce bootloader size
    truncate --size 0 mk/devel.mk
  '';

  # preBuild = ''
  #   mkdir -p $out
  #   cp -r ${gnu-efi}/* $out
  #   mkdir efi64
  #   cp -r ${gnu-efi}/* ./efi64
  # '';

  stripDebugList = "bin sbin share/syslinux/com32";

  makeFlags = [
    "BINDIR=$(out)/bin"
    "SBINDIR=$(out)/sbin"
    "LIBDIR=$(out)/lib"
    "INCDIR=$(out)/include"
    "DATADIR=$(out)/share"
    "MANDIR=$(out)/share/man"
    "PERL=perl"
    # "bios"
    "efi64"
  ];

  postInstall = ''
    wrapProgram $out/bin/syslinux \
      --prefix PATH : "${mtools}/bin"
  '';

  meta = with stdenv.lib; {
    homepage = http://www.syslinux.org/;
    description = "A lightweight bootloader";
    license = licenses.gpl2;
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
