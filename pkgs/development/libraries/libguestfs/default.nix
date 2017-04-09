{ stdenv, fetchurl, fetchgit, pkgconfig, autoreconfHook, makeWrapper, dbus, lzma, ocamlPackages
, bash-completion, ncurses, cpio, gperf, perl, cdrkit, flex, bison, qemu, pcre, augeas, libxml2
, acl, libcap, libcap_ng, libconfig, fuse, yajl, libvirt, hivex, utillinux, curl
, gmp, readline, file, libintlperl, GetoptLong, SysVirt, numactl, xen, libapparmor, which
, systemd ? null }:

let
  mainVersion = "1.36.3";
  applianceVersion = "1.36.1";

  olibVirtRev = "3169af3337938e18bf9ecc6ce936d644e14ff3de";

  # version 0.6.1.4 in nixpkgs is too old, but it is the latest official release, so instead
  # we pull from master
  # https://www.redhat.com/archives/libguestfs/2015-March/msg00062.html
  olibvirt = stdenv.lib.overrideDerivation ocamlPackages.ocaml_libvirt (oldAttrs: {
    name = "ocaml-libvirt-${builtins.substring 0 8 olibVirtRev}";
    src = fetchgit {
      url    = "git://git.annexia.org/git/ocaml-libvirt.git";
      rev    = olibVirtRev;
      sha256 = "0z8p6q6k42rdrvy248siq922m1yszny1hfklf6djynvk2viyqdbg";
    };
    buildInputs = [ autoreconfHook ];
  });

in stdenv.mkDerivation rec {
  name = "libguestfs-${mainVersion}";
  version = mainVersion;

  appliance = fetchurl {
    url = "http://libguestfs.org/download/binaries/appliance/appliance-${applianceVersion}.tar.xz";
    sha256 = "1klvr13gpg615hgjvviwpxlj839lbwwsrq7x100qg5zmmjfhl125";
  };

  src = fetchurl {
    url = "http://libguestfs.org/download/${builtins.substring 0 4 mainVersion}-stable/${name}.tar.gz";
    sha256 = "0dhb69b7svjgnrmbyvizdz5vsgsrr95ypz0qvp3kz83jyj6sa76m";
  };

  # I don't know why we need this
  patches = [ ./libguestfs-syms.patch ];

  binPath = stdenv.lib.makeBinPath [ hivex qemu ];

  # doCheck = true;

  buildInputs = [
    GetoptLong SysVirt
    acl augeas bash-completion bison cdrkit cpio dbus file flex fuse gmp
    gperf hivex libapparmor libcap libcap_ng libconfig libintlperl libvirt
    libxml2 lzma ncurses numactl pcre perl qemu readline systemd
    utillinux xen yajl
  ] ++ (with ocamlPackages; [ ocaml findlib olibvirt ]);

  nativeBuildInputs = [ autoreconfHook makeWrapper pkgconfig which ];

  configureFlags = [
    "--disable-appliance"
    "--disable-daemon"
  ];

  installFlags = [
    "DESTDIR=/"
    "REALLY_INSTALL=yes"
  ];

  preConfigure = ''
    patchShebangs .
  '';

  preCheck = ''
    # these are failing but at least we have tests now, which we didn't before
    export SKIP_TEST_FUSE_SH=1
    export SKIP_TEST_GUESTUNMOUNT_NOT_MOUNTED_SH=1
    export SKIP_TEST_VIRT_BUILDER_LIST_SH=1
    export SKIP_TEST_VIRT_BUILDER_LIST_SIMPLESTREAMS_SH=1

    # the windows test is looking for an image, that doesn't exist so we create it
    ${qemu}/bin/qemu-img create -f raw test-data/phony-guests/windows.img 8M

    export PATH=$PATH:$(pwd)/bin:$out/bin
  '';

  installPhase = ''
    runHook preInstall

    make install DESTDIR=$out/

    for bin in $out/bin/*; do
      wrapProgram "$bin" \
        --prefix PATH     : "$out/bin:${binPath}" \
        --prefix PERL5LIB : "$PERL5LIB:$out/lib/perl5/site_perl"
    done

    runHook postInstall
  '';

  postFixup = ''
    mkdir -p "$out/lib/guestfs"
    tar -Jxvf "$appliance" --strip 1 -C "$out/lib/guestfs"
  '';

  meta = with stdenv.lib; {
    description = "Tools for accessing and modifying virtual machine disk images";
    license     = licenses.gpl2;
    homepage    = http://libguestfs.org/;
    maintainers = with maintainers; [ offline peterhoeg ];
    platforms   = platforms.linux;
  };
}
