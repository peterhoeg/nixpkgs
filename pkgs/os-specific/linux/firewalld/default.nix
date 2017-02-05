{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, qtbase
, wrapQtAppsHook
, docbook_xml_dtd_42
, gettext
, python3Packages
, intltool
, dbus
, pkg-config
, iptables
, ebtables
, ipset
, glib
, kmod
, procps
, gobject-introspection
, withKde ? true
, plasma-nm ? null
}:
let
  slip = python3Packages.buildPythonPackage rec {
    pname = "python-slip";
    version = "0.6.5";

    format = "other";

    src = fetchFromGitHub {
      owner = "nphilipp";
      repo = "python-slip";
      rev = "${pname}-${version}";
      sha256 = "sha256-FkNtmz/NObzpDGXr5CaEdwtaiAXlNi05Vh1TmTTFSE4=";
    };

    PREFIX = placeholder "out";

    doCheck = false; # no tests
  };

in
# python3Packages.buildPythonApplication rec {
stdenv.mkDerivation rec {
  pname = "firewalld";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "firewalld";
    repo = "firewalld";
    rev = "v${version}";
    sha256 = "sha256-BEYMVvon1hWq3A8yZ1eQtCF2+91Ea11S2cw4Lt6V5/8=";
  };

  # format = "other";

  # doCheck = false; # no tests

  propagatedBuildInputs = with python3Packages; [
    dbus
    decorator
    pygobject3
    pyqt5
    slip
  ];

  nativeBuildInputs = [
    gobject-introspection
    autoreconfHook
    intltool
    pkg-config
    docbook_xml_dtd_42
    gettext
    wrapQtAppsHook
    python3Packages.wrapPython
  ];

  buildInputs = [
    qtbase
    gobject-introspection
    dbus
    ebtables
    glib
    ipset
    iptables
  ];

  configureFlags = [
    "--disable-docs"
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;
  dontWrapPythonPrograms = true;

  EBTABLES = "${ebtables}/bin/ebtables";
  EBTABLES_RESTORE = "${ebtables}/bin/ebtables_restore";
  IPSET = "${ipset}/bin/ipset";
  IPTABLES = "${iptables}/bin/iptables";
  IPTABLES_RESTORE = "${iptables}/bin/iptables-restore";
  IP6TABLES = "${iptables}/bin/ip6tables";
  IP6TABLES_RESTORE = "${iptables}/bin/ip6tables-restore";
  MODINFO = "${kmod}/bin/modinfo";
  MODPROBE = "${kmod}/bin/modprobe";
  RMMOD = "${kmod}/bin/rmmod";
  SYSCTL = "${procps}/bin/sysctl";

  postPatch = ''
    patchShebangs .

    substituteInPlace src/firewall-applet.in \
      --replace /usr/bin/kde5-nm-connection-editor ${lib.getBin plasma-nm}/bin/kde5-nm-connection-editor
  '';

  postInstall = ''
    cp -r config/{helpers,icmptypes,ipsets,services,zones} $out/etc/firewalld
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    description = "A service daemon with D-Bus interface";
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
