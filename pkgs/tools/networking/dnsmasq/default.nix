{ stdenv, fetchurl, pkgconfig, dbus_libs, nettle, libidn, libnetfilter_conntrack, fetchpatch }:

with stdenv.lib;

let
  copts = concatStringsSep " " ([
    "-DHAVE_IDN"
    "-DHAVE_DNSSEC"
  ] ++ optionals stdenv.isLinux [
    "-DHAVE_DBUS"
    "-DHAVE_CONNTRACK"
  ]);

in stdenv.mkDerivation rec {
  name = "dnsmasq-2.79";

  src = fetchurl {
    url = "http://www.thekelleys.org.uk/dnsmasq/${name}.tar.xz";
    sha256 = "07w6cw706yyahwvbvslhkrbjf2ynv567cgy9pal8bz8lrbsp9bbq";
  };

  patches = [
    # (fetchpatch {
      # name = "CVE-2017-15107.patch";
      # url = "http://thekelleys.org.uk/gitweb/?p=dnsmasq.git;a=patch;h=4fe6744a220eddd3f1749b40cac3dfc510787de6";
      # sha256 = "0r8grhh1q46z8v6manx1vvfpf2vmchfzsg7l1djh63b1fy1mbjkk";
      # changelog does not apply cleanly but its safe to skip
      # excludes = [ "CHANGELOG" ];
    # })
  ];

  preBuild = ''
    makeFlagsArray=("COPTS=${copts}")
  '';

  makeFlags = [
    "DESTDIR="
    "BINDIR=$(out)/bin"
    "MANDIR=$(out)/man"
    "LOCALEDIR=$(out)/share/locale"
  ];

  hardeningEnable = [ "pie" ];

  enableParallelBuilding = true;

  postBuild = optionalString stdenv.isLinux ''
    make -C contrib/lease-tools
  '';

  # XXX: Does the systemd service definition really belong here when our NixOS
  # module can create it in Nix-land?
  postInstall = ''
    install -Dm644 trust-anchors.conf $out/share/dnsmasq/trust-anchors.conf
  '' + optionalString stdenv.isDarwin ''
    install -Dm644 contrib/MacOSX-launchd/uk.org.thekelleys.dnsmasq.plist \
      $out/Library/LaunchDaemons/uk.org.thekelleys.dnsmasq.plist
    substituteInPlace $out/Library/LaunchDaemons/uk.org.thekelleys.dnsmasq.plist \
      --replace "/usr/local/sbin" "$out/bin"
  '' + optionalString stdenv.isLinux ''
    mkdir -p $out/etc/dbus-1/system.d
    cat <<END > $out/etc/dbus-1/system.d/dnsmasq.conf
    <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
    <busconfig>
      <policy user="root">
        <allow own="uk.org.thekelleys.dnsmasq"/>
        <allow send_destination="uk.org.thekelleys.dnsmasq"/>
      </policy>
      <policy user="dnsmasq">
        <allow own="uk.org.thekelleys.dnsmasq"/>
        <allow send_destination="uk.org.thekelleys.dnsmasq"/>
      </policy>
      <policy context="default">
        <deny own="uk.org.thekelleys.dnsmasq"/>
        <deny send_destination="uk.org.thekelleys.dnsmasq"/>
      </policy>
    </busconfig>
    END
    install -Dm755 -t $out/bin contrib/lease-tools/dhcp_{lease_time,release,release6}

    mkdir -p $out/share/dbus-1/system-services
    cat <<END > $out/share/dbus-1/system-services/uk.org.thekelleys.dnsmasq.service
    [D-BUS Service]
    Name=uk.org.thekelleys.dnsmasq
    Exec=$out/bin/dnsmasq -k -1
    User=root
    SystemdService=dnsmasq.service
    END
  '';

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ nettle libidn ]
    ++ optionals stdenv.isLinux [ dbus_libs libnetfilter_conntrack ];

  meta = {
    description = "An integrated DNS, DHCP and TFTP server for small networks";
    homepage = http://www.thekelleys.org.uk/dnsmasq/doc.html;
    license = licenses.gpl2;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ eelco fpletz ];
  };
}
