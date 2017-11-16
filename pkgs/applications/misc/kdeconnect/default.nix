{ mkDerivation, lib, fetchurl, extra-cmake-modules, makeWrapper, writeText
, kcmutils, kconfigwidgets, kdbusaddons, kdoctools, kiconthemes
, ki18n, knotifications, kwayland
, qtbase, qtx11extras, qca-qt5
, libfakekey, libXtst, sshfs
}:

let
  busName = "org.kde.kdeconnect";

  service = writeText "kdeconnectd.service" ''
    [Unit]
    Description = KDE Connect

    [Service]
    Environment = "QML2_IMPORT_PATH=${qtbase.bin}/${qtbase.qtQmlPrefix}"
    Environment = "QT_PLUGIN_PATH=${qtbase.bin}/${qtbase.qtPluginPrefix}"
    Type = dbus
    BusName = ${busName}
    ExecStart = @out@/libexec/kdeconnectd
    Restart = on-failure
    Slice = kde.slice
  '';

in mkDerivation rec {
  pname = "kdeconnect";
  version = "1.3.5";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${version}/${pname}-kde-${version}.tar.xz";
    sha256 = "02lr3xx5s2mgddac4n3lkgr7ppf1z5m6ajs90rjix0vs8a271kp5";
  };

  buildInputs = [
    libfakekey libXtst
    ki18n kiconthemes kcmutils kconfigwidgets kdbusaddons knotifications kwayland
    qca-qt5 qtx11extras
  ];

  nativeBuildInputs = [ extra-cmake-modules kdoctools makeWrapper ];

  postInstall = ''
    wrapProgram $out/libexec/kdeconnectd \
      --prefix PATH : ${lib.makeBinPath [ sshfs ]}

    echo "SystemdService=dbus-${busName}.service" >> $out/share/dbus-1/services/${busName}.service
    mkdir -p $out/lib/systemd/user
    substitute ${service} $out/lib/systemd/user/kdeconnectd.service \
      --subst-var out
    ln -s $out/lib/systemd/user/kdeconnectd.service $out/lib/systemd/user/dbus-${busName}.service
    sed -i $out/etc/xdg/autostart/${busName}.daemon.desktop \
      -e 's@^Exec.*@Exec=systemctl --user start kdeconnectd.service@'
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "KDE Connect provides several features to integrate your phone and your computer";
    homepage    = https://community.kde.org/KDEConnect;
    license     = with licenses; [ gpl2 ];
    maintainers = with maintainers; [ fridh ];
  };
}
