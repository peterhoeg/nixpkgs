{ stdenv, lib, fetchurl, makeWrapper, unzip
, bluez, gawk, procps, udev
, withAddons ? false
, withLegacyAddons ? false
, addons ? [] }:

let
  version = "2.4.0";

  addon = stdenv.mkDerivation rec {
    pname = "openhab-addons";
    inherit version;

    src = fetchurl {
      url = "https://bintray.com/openhab/mvn/download_file?file_path=org/openhab/distro/${pname}/${version}/${pname}-${version}.kar";
      sha256 = "1ywhfc9rj7bapi42za9w2sybz6vhclaf23dklfgb00gvjm82mxyc";
    };

    buildCommand = ''
      install -Dm444 $src $out/share/java/${src.name}
    '';
  };

  legacyAddon = stdenv.mkDerivation rec {
    pname = "openhab-addons-legacy";
    inherit version;

    src = fetchurl {
      url = "https://bintray.com/openhab/mvn/download_file?file_path=org/openhab/distro/${pname}/${version}/${pname}-${version}.kar";
      sha256 = "12zznb0pla15zbaamjw27jn29gi571nbdkaacz685aq47dr8w891";
    };

    buildCommand = ''
      install -Dm444 $src $out/share/java/${src.name}
    '';
  };

  actualAddons = addons
    ++ lib.optional withAddons addon
    ++ lib.optional withLegacyAddons legacyAddon;

in stdenv.mkDerivation rec {
  pname = "openhab";
  inherit version;

  src = fetchurl {
    url = "https://bintray.com/openhab/mvn/download_file?file_path=org/openhab/distro/openhab/${version}/openhab-${version}.zip";
    sha256 = "1hl9pmk97kywni0p168f4yzhm4zfgr5vcxfbf4lirgac7h9hgamb";
  };

  unpackPhase = ''
    runHook preUnpack
    runHook postUnpack
  '';

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dir=$out/share/openhab

    mkdir -p $out/{bin,share/openhab}

    unzip -q $src -d $dir/

    ${lib.concatStringsSep "\n" (map (e: ''
      for f in ${e}/share/java/* ; do
        ln -s $f $dir/addons/
      done
    '') actualAddons)}

    makeWrapper $out/share/openhab/runtime/bin/karaf $out/bin/openhab \
      --set-default OPENHAB_HOME $dir \
      --set-default OPENHAB_CONF /var/lib/openhab/conf \
      --set-default OPENHAB_USERDATA /var/lib/openhab/userdata \
      --set-default OPENHAB_LOGDIR /var/log/openhab \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ bluez udev ]} \
      --prefix PATH : /run/wrappers/bin:${lib.makeBinPath [ gawk procps ]}

    chmod 555 $out/bin/*

    runHook postInstall
  '';

  nativeBuildInputs = [ makeWrapper unzip ];

  meta = with stdenv.lib; {
    description = "OpenHAB - home automation";
    homepage = https://www.openhab.org;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
