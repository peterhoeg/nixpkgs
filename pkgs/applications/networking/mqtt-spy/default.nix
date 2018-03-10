{ stdenv, fetchurl, jre, makeWrapper }:

let
  beta = "13";
  shortVersion = "1.0.1";

in stdenv.mkDerivation rec {
  name = "meterbridge-${version}";
  version = "${shortVersion}-beta${beta}";

  src = fetchurl {
    url = "https://github.com/eclipse/paho.mqtt-spy/releases/download/${version}/mqtt-spy-${shortVersion}-beta-b${beta}-jar-with-dependencies.jar";
    sha256 = "0469r159zf0ml20385a480l3qy5rfbn6z02aglxkkknx2ccc446r";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = ":";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/mqtt-spy}
    install -m644 $src $out/share/mqtt-spy/mqtt-spy-${version}.jar
    makeWrapper ${stdenv.lib.getBin jre}/bin/java $out/bin/mqtt-spy \
      --add-flags "-jar $out/share/mqtt-spy/mqtt-spy-${version}.jar"

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Desktop & CLI utility intended to help you with monitoring activity on MQTT topics";
    homepage    = https://github.com/eclipse/paho.mqtt-spy/wiki;
    license     = licenses.epl10;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (jre.meta) platforms;
  };
}
