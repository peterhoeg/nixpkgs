{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config
, qtbase
, wrapGAppsHook
, wrapQtAppsHook
, docbook_xml_dtd_42
, gettext
, python3Packages
, intltool
, atk
, dbus
, ebtables
, glib
, gobject-introspection
, gtk3
, ipset
, iptables
, kmod
, libnotify
, nftables
, pango
, procps
}:

# NOTE: firewall-applet (the KDE bit) isn't working yet

let
  pypkgs = python3Packages;

  inherit (lib) optional optionalString;

in
pypkgs.buildPythonApplication rec {
  pname = "firewalld";
  version = "1.0.0";

  format = "other";

  src = fetchFromGitHub {
    owner = "firewalld";
    repo = "firewalld";
    rev = "v${version}";
    sha256 = "sha256-UfTy/jU6pxoJK8twxhoM2qGd2qYVxZQLAj7gcDMj93E=";
  };

  postPatch = ''
    patchShebangs ./src

    substituteInPlace src/firewall-applet.in \
      --replace /usr/bin/kde5-nm-connection-editor /run/current-system/bin/kde5-nm-connection-editor

    substituteInPlace src/firewall/config/__init__.py.in \
      --replace /usr/share $out/share
  '';

  propagatedBuildInputs = with pypkgs; [
    dbus-python
    (nftables.override { withPython = true; })
    pygobject3
    pyqt5
  ];

  buildInputs = [
    atk
    dbus
    glib
    gobject-introspection
    gtk3
    libnotify
    pango
    qtbase
    # these are deprecated:
    ebtables
    ipset
    iptables
  ];

  nativeBuildInputs = [
    autoreconfHook
    docbook_xml_dtd_42
    gettext
    gobject-introspection
    intltool
    pkg-config
    wrapGAppsHook
    wrapQtAppsHook
  ];

  configureFlags = [ "--disable-docs " ];

  MODINFO = "${kmod}/bin/modinfo";
  MODPROBE = "${kmod}/bin/modprobe";
  RMMOD = "${kmod}/bin/rmmod";
  SYSCTL = "${procps}/bin/sysctl";

  # these are all deprecated (but still supported) as nftables it the future
  EBTABLES = "${ebtables}/bin/ebtables";
  EBTABLES_RESTORE = "${ebtables}/bin/ebtables_restore";
  IPSET = "${ipset}/bin/ipset";
  IPTABLES = "${iptables}/bin/iptables";
  IPTABLES_RESTORE = "${iptables}/bin/iptables-restore";
  IP6TABLES = "${iptables}/bin/ip6tables";
  IP6TABLES_RESTORE = "${iptables}/bin/ip6tables-restore";

  postInstall = ''
    cp -r config/{helpers,icmptypes,ipsets,services,zones} $out/etc/firewalld
  '';

  doCheck = false;

  dontWrapGApps = true;
  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Firewall daemon with D-Bus interface";
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
