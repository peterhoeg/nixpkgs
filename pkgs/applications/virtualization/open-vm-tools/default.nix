{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, autoreconfHook
, fuse
, libmspack
, openssl
, pam
, xercesc
, icu
, libdnet
, procps
, libtirpc
, rpcsvc-proto
, libxml2
, libX11
, libXext
, libXinerama
, libXi
, libXrender
, libXrandr
, libXtst
, pkg-config
, glib
, gdk-pixbuf-xlib
, gtk3
, gtkmm3
, iproute
, dbus
, systemd
, which
, withX ? true
}:

stdenv.mkDerivation rec {
  pname = "open-vm-tools";
  version = "11.2.5";

  src = fetchFromGitHub {
    owner = "vmware";
    repo = "open-vm-tools";
    rev = "stable-${version}";
    sha256 = "sha256-Jv+NSKw/+l+b4lfVGgCZFlcTScO/WAO/d7DtI0FAEV4=";
  };

  sourceRoot = "${src.name}/open-vm-tools";

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ autoreconfHook makeWrapper pkg-config ];

  buildInputs = [ fuse glib icu libdnet libmspack libtirpc libxml2 openssl pam procps rpcsvc-proto systemd xercesc ]
    ++ lib.optionals withX [ gdk-pixbuf-xlib gtk3 gtkmm3 libX11 libXext libXinerama libXi libXrender libXrandr libXtst ];

  postPatch = ''
    substituteInPlace Makefile.am \
      --replace 'etc/vmware-tools' '${placeholder "out"}/libexec/vmware-tools'

    sed -i scripts/Makefile.am \
      -e 's,^confdir = ,confdir = ${placeholder "out"},' \
      -e 's,usr/bin,${placeholder "out"}/bin,'

    substituteInPlace services/vmtoolsd/Makefile.am \
      --replace 'etc/vmware-tools' '${placeholder "out"}/libexec/vmware-tools' \
      --replace '$(PAM_PREFIX)'    '${placeholder "out"}/$(PAM_PREFIX)'

    substituteInPlace udev/Makefile.am \
      --replace '$(UDEVRULESDIR)' '${placeholder "out"}/$(UDEVRULESDIR)'

    # Make reboot work, shutdown is not in /sbin on NixOS
    substituteInPlace lib/system/systemLinux.c \
      --replace '/sbin/shutdown -r now' '${lib.getBin systemd}/bin/systemctl reboot' \
      --replace '/sbin/shutdown -p now' '${lib.getBin systemd}/bin/systemctl poweroff'
  '';

  configureFlags = [
    "--with-udev-rules-dir=${placeholder "out"}/lib/udev/rules.d"
    "--with-xml2"
  ]
  ++ lib.optional (!withX) "--without-x";

  enableParallelBuilding = true;

  postInstall = ''
    wrapProgram "$out/etc/vmware-tools/scripts/vmware/network" \
      --prefix PATH ':' "${lib.makeBinPath [ dbus iproute systemd which ]}"
  '';

  meta = with lib; {
    homepage = "https://github.com/vmware/open-vm-tools";
    description = "Set of tools for VMWare guests to improve host-guest interaction";
    longDescription = ''
      A set of services and modules that enable several features in VMware products for
      better management of, and seamless user interactions with, guests.
    '';
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ joamaki ];
  };
}
