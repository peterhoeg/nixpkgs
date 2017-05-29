{ stdenv, fetchurl, makeWrapper, jdk, buildMaven, maven, which }:

stdenv.mkDerivation rec {
  name = "jruby-${version}";

  version = "9.1.10.0";

  src = fetchurl {
    url = "https://s3.amazonaws.com/jruby.org/downloads/${version}/jruby-src-${version}.tar.gz";
    sha256 = "1xihzaqg47d0blh1hcpd4zyp11dhd3w9n57mcx498nw4azw6pxla";
  };

  preBuild = ''
    set -x

    export JAVA_HOME=${jdk}
    export M2_HOME=${maven}/maven
    ./mvnw
  '';

  buildInputs = [ jdk ];
  nativeBuildInputs = [ makeWrapper maven which ];

  # nativeBuildInputs = [ buildMaven makeWrapper ];

  # installPhase = ''
  #    mkdir -pv $out/docs
  #    mv * $out
  #    rm $out/bin/*.{bat,dll,exe,sh}
  #    mv $out/COPYING $out/LICENSE* $out/docs

  #    for i in $out/bin/*; do
  #      wrapProgram $i \
  #        --set JAVA_HOME ${jre}
  #    done
  # '';

  meta = with stdenv.lib; {
    description = "Ruby interpreter written in Java";
    homepage = http://jruby.org/;
    license = with licenses; [ cpl10 gpl2 lgpl21 ];
    platforms = platforms.unix;
  };
}
