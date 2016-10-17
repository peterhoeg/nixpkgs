{ kdeFramework, lib, ecm, kauth, kconfig
, kcoreaddons, kcrash, kdbusaddons, kfilemetadata, ki18n, kidletime
, kio, lmdb, qtbase, solid, writeText
}:

let
  busName = "org.kde.baloo";
  serviceName = "baloo.service";

  dbus = writeText "dbus-${serviceName}" ''
    [D-BUS Service]
    Name=${busName}
    Exec=@out@/bin/baloo_file
    SystemdService=dbus-${busName}.service
  '';

  service = writeText serviceName ''
    [Unit]
    Description=Baloo File Indexer

    [Service]
    Type=dbus
    BusName=${busName}
    ExecStart=@out@/bin/baloo_file
    ExecStop=@out@/bin/balooctl stop
    ExecReload=@out@/bin/balooctl reload
    Restart=on-failure
    PrivateTmp=true
    Slice=kde.slice
    Nice=10
  '';

in kdeFramework {
  name = "baloo";
  meta = { maintainers = [ lib.maintainers.ttuegel ]; };
  nativeBuildInputs = [ ecm ];
  propagatedBuildInputs = [
    kauth kconfig kcoreaddons kcrash kdbusaddons kfilemetadata ki18n kio
    kidletime lmdb qtbase solid
  ];

  postInstall = ''
    mkdir -p $out/lib/systemd/user $out/share/dbus-1/services
    sed "s|@out@|$out|g" ${service} > $out/lib/systemd/user/${serviceName}
    ln -sr $out/lib/systemd/user/${serviceName} $out/lib/systemd/user/dbus-${busName}.service

    rm -f $out/etc/xdg/autostart/${serviceName}

    sed "s|@out@|$out|g" ${dbus} > $out/share/dbus-1/services/${busName}.service
  '';
}
