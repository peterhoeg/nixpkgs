{ stdenv
, lib
, fetchurl
, extra-cmake-modules
, kcmutils
, kconfigwidgets
, kdbusaddons
, kdoctools
, kiconthemes
, ki18n
, knotifications
, qca-qt5
, libfakekey
, libXtst
, qtbase
, qtx11extras
, sshfs
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "kdeconnect";
  version = "1.2.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${version}/src/${pname}-kde-v${version}.tar.xz";
    sha256 = "01v432p9ylwss9gl6fvby8954bnjd91dni5jk1i44vv7x26yn8zg";
  };

  buildInputs = [
    libfakekey libXtst
    ki18n kiconthemes kcmutils kconfigwidgets kdbusaddons knotifications
    qca-qt5 qtx11extras makeWrapper
  ];

  nativeBuildInputs = [ extra-cmake-modules kdoctools ];

  postInstall = ''
    wrapProgram $out/lib/libexec/kdeconnectd --prefix PATH : ${lib.makeBinPath [ sshfs ]}

    echo "SystemdService=dbus-org.kde.kdeconnect.service" >> $out/share/dbus-1/services/org.kde.kdeconnect.service
    mkdir -p $out/lib/systemd/user
    cat << _EOF > $out/lib/systemd/user/dbus-org.kde.kdeconnect.service
    [Unit]
    Description=KDE Connect

    [Service]
    Environment="QML2_IMPORT_PATH=/run/current-system/sw/${qtbase.qtPluginPrefix}"
    Environment="QT_PLUGIN_PATH=/run/current-system/sw/${qtbase.qtQmlPrefix}"
    Type=dbus
    BusName=org.kde.kdeconnectd
    ExecStart=$out/lib/libexec/kdeconnectd
    Restart=on-failure
    Slice=kde.slice
    _EOF
    rm $out/etc/xdg/autostart/kdeconnectd.desktop
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "KDE Connect provides several features to integrate your phone and your computer";
    homepage    = https://community.kde.org/KDEConnect;
    license     = with licenses; [ gpl2 ];
    maintainers = with maintainers; [ fridh ];
  };
}
