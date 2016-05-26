{ stdenv, fetchurl, makeWrapper
, atk, cairo, gdk_pixbuf, ghostscript, glib, glibc, gtk, pango, jdk, swt }:

let
  libPath = stdenv.lib.makeLibraryPath [
    atk cairo gdk_pixbuf ghostscript glib gtk jdk pango swt
  ];
  binPath = stdenv.lib.makeBinPath [
    ghostscript jdk
  ];

in stdenv.mkDerivation rec {
  name = "cabaretstage-${version}";
  version = "6.0.2";

  src = fetchurl {
    url = "https://www.cabaret-solutions.com/system/files/cabaretstage_${version}_linux-64bit.tar_.gz";
    sha256 = "1klvml439dlnfzni8w8pi1rd4w9g4s3y2vc57frrvvfkk6vkm5n8";
  };

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = ''
    mkdir -p $out/share

    cp -r cabaretstage-${version}/* $out/
    rm $out/bin/cabaretstage.sh
    mv $out/cabaret.png $out/share

    wrapProgram $out/bin/cabaretstage \
      --set CLASSPATH $out/lib/\* \
      --set JAVA_HOME ${jdk.home} \
      --suffix LD_LIBRARY_PATH : ${libPath}:$out/lib/amd64 \
      --prefix PATH : ${binPath}:$out/bin

    patchelf --set-interpreter ${glibc.out}/lib/ld-linux-x86-64.so.2 \
      $out/bin/.cabaretstage-wrapped
  '';

  buildInputs = [ makeWrapper ];

  # propagatedBuildInputs = [ jdk swt ];

  meta = {
    description = "PDF editor";
    maintainers = [ stdenv.lib.maintainers.peterhoeg ];
  };
}
