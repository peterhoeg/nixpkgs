{ stdenv, fetchFromGitHub, fetchurl, nasm, perl, python, libuuid, mtools, makeWrapper }:

stdenv.mkDerivation rec {
  name = "syslinux-2017-11-23";

  src = fetchFromGitHub {
    owner = "geneC";
    repo = "syslinux";
    rev = "2ea44cbedb297bd6b409d5c1e0402d5f89592be4";
    sha256 = "1rb1gngr67r401w59zj1z2w850cwn4w0lb5pdxayz7kbvnx5bvv9";
  };

  patches = [
    # ./perl-deps.patch
  #   (fetchurl {
  #     # ldlinux.elf: Not enough room for program headers, try linking with -N
  #     name = "not-enough-room.patch";
  #     url = "https://anonscm.debian.org/cgit/collab-maint/syslinux.git/plain/"
  #         + "debian/patches/0014_fix_ftbfs_no_dynamic_linker.patch?id=a556ad7";
  #     sha256 = "0ijqjsjmnphmvsx0z6ppnajsfv6xh6crshy44i2a5klxw4nlvrsw";
  #   })
  ];

  nativeBuildInputs = [ nasm perl python ];
  buildInputs = [ libuuid makeWrapper ];

  enableParallelBuilding = true; # Fails very rarely with 'No rule to make target: ...'
  hardeningDisable = [ "pic" "stackprotector" "fortify" ];

  preBuild = ''
    substituteInPlace Makefile --replace /bin/pwd $(type -P pwd)
    substituteInPlace utils/ppmtolss16 --replace /usr/bin/perl $(type -P perl)
    # substituteInPlace gpxe/src/Makefile.housekeeping --replace /bin/echo $(type -P echo)
    # substituteInPlace gpxe/src/Makefile --replace /usr/bin/perl $(type -P perl)
  '';

  stripDebugList = "bin sbin share/syslinux/com32";

  makeFlags = [
    "BINDIR=$(out)/bin"
    "SBINDIR=$(out)/sbin"
    "LIBDIR=$(out)/lib"
    "INCDIR=$(out)/include"
    "DATADIR=$(out)/share"
    "MANDIR=$(out)/share/man"
    "PERL=perl"
    "bios"
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
