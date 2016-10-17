{ kdeFramework, lib, ecm, kconfig, kconfigwidgets
, kcoreaddons , kdbusaddons, kdoctools, ki18n, kiconthemes
, knotifications , kservice, kwidgetsaddons, kwindowsystem, libgcrypt
, writeText
}:

let
  busName = "org.kde.kwalletd5";
  serviceName = "kwalletd5.service";

  dbus = writeText "dbus-${serviceName}" ''
    [D-BUS Service]
    Name=${busName}
    Exec=@out@/bin/kwalletd5
    SystemdService=dbus-${busName}.service
  '';

  service = writeText serviceName ''
    [Unit]
    Description=KDE Wallet

    [Service]
    Type=dbus
    BusName=${busName}
    ExecStart=@out@/bin/kwalletd5
    ExecStop=${kdbusaddons}/bin/kquitapp5 kwalletd5
    Restart=on-failure
    PrivateTmp=true
    Slice=kde.slice
  '';

in kdeFramework {
  name = "kwallet";
  meta = { maintainers = [ lib.maintainers.ttuegel ]; };
  nativeBuildInputs = [ ecm kdoctools ];
  propagatedBuildInputs = [
    kconfig kconfigwidgets kcoreaddons kdbusaddons ki18n kiconthemes
    knotifications kservice kwidgetsaddons kwindowsystem libgcrypt
  ];

  postInstall = ''
    mkdir -p $out/lib/systemd/user
    sed "s|@out@|$out|g" ${service} > $out/lib/systemd/user/${serviceName}
    ln -sr $out/lib/systemd/user/${serviceName} $out/lib/systemd/user/dbus-${busName}.service

    rm -f $out/etc/xdg/autostart/${serviceName}

    sed "s|@out@|$out|g" ${dbus} > $out/share/dbus-1/services/${busName}.service
  '';
}
