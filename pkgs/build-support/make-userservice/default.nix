{ stdenv, lib, systemd, writeScript, procps ? null, qt5 ? null }:

{ name
, description
, dbus ? ""
, exec
, environment ? {}
, kdeApp ? false
}:

let
  preKde = name: dbus: exec: writeScript "pre-kde-service.sh" ''
    #!${stdenv.shell} -eu

    # ${lib.getBin systemd}/bin/systemctl --user import-environment QT_SCREEN_SCALE_FACTORS QT_QUICK_CONTROLS_STYLE

    # kill non-dbus/service spawned binaries
    ${lib.getBin qt5.qttools}/bin/qdbus ${dbus} / ${dbus}.main.quit || true
    ${lib.optionalString stdenv.isLinux ''
      ${lib.getBin procps}/bin/pkill ${exec} || true
    ''}
  '';

in stdenv.mkDerivation {
  name = "${name}.services";
  buildCommand = ''
    mkdir -p $out
    cat > $out/${name}.service <<EOF
    [Unit]
    Description=${description}

    [Service]
    ${lib.optionalString kdeApp ''
      Environment="QT_PLUGIN_PATH="/run/current-system/sw/${qt5.qtbase.qtPluginPrefix}"
      Environment="QML2_IMPORT_PATH="/run/current-system/sw/${qt5.qtbase.qtQmlPrefix}"
      ExecStartPre=-${preKde name dbus exec}
    ''}
    ${lib.optionalString (!(dbus == "")) ''
    Type=${if (dbus == "") then "simple" else "dbus"}
    BusName=${dbus}
    ''}
    ExecStart=@out@/${exec}
    EOF
  '';
}
