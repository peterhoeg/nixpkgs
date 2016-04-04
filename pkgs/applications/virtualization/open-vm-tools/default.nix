{ stdenv, lib, fetchurl, makeWrapper, autoreconfHook,
  libmspack, openssl, pam, xercesc, icu, libdnet, procps,
  xlibsWrapper, libXinerama, libXi, libXrender, libXrandr, libXtst,
  pkgconfig, cunit, fuse, glib, gtk, gtkmm }:

let
  majorVersion = "10.0";
  minorVersion = "7";
  version = "${majorVersion}.${minorVersion}";

in stdenv.mkDerivation {
  name = "open-vm-tools-${version}";
  src = fetchurl {
    url = "https://github.com/vmware/open-vm-tools/archive/stable-${version}.tar.gz";
    sha256 = "1j1fm6sv2rqgg04ifr9s975i93wyr0523iw0mv7xqfgxmz1nvmw7";
  };

  sourceRoot = "open-vm-tools-stable-${version}/open-vm-tools";

  buildInputs =
    [ autoreconfHook makeWrapper libmspack openssl pam xercesc cunit fuse icu libdnet procps
      pkgconfig glib gtk gtkmm xlibsWrapper libXinerama libXi libXrender libXrandr libXtst ];

  prePatch = ''
     sed -i s,-Werror,,g configure.ac
     sed -i 's,^confdir = ,confdir = ''${prefix},' scripts/Makefile.am
     sed -i 's,etc/vmware-tools,''${prefix}/etc/vmware-tools,' services/vmtoolsd/Makefile.am
  
     sed -i 's,defined(linux),defined(linux) || defined(__linux),g' lib/include/*.h
  '';

  patches = [ 
    ./subdir-objects.patch
  ];

  configureFlags = "--disable-docs --without-kernel-modules --without-xmlsecurity";

  meta = with stdenv.lib; {
    homepage = "https://github.com/vmware/open-vm-tools";
    description = "Set of tools for VMWare guests to improve host-guest interaction";
    longDescription = ''
      A set of services and modules that enable several features in VMware products for 
      better management of, and seamless user interactions with, guests. 
    '';
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ joamaki ];
  };
}
