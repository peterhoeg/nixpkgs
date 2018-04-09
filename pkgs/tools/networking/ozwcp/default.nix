{ stdenv, fetchFromGitHub, doxygen, pkgconfig, which
, libmicrohttpd, openzwave, systemd }:

stdenv.mkDerivation rec {
  name = "ozwcp-${version}";
  version = "20170321";

  src = fetchFromGitHub {
    owner = "OpenZWave";
    repo = "open-zwave-control-panel";
    rev = "bbbd461c5763faab4949b12da12901f2d6f00f48";
    sha256 = "1b820zjjdw15gy88y2qsrkhbxnska9gwqig4nd29s631l62smknd";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/local/lib     ${libmicrohttpd}/lib \
      --replace /usr/local/include ${libmicrohttpd}/include \
      --replace '-framework IOKit -framework CoreFoundation' '-ludev' \
      --replace ../open-zwave/ ${openzwave.src} \
      --replace '@exit 1' ""
  '';

  buildInputs = [ libmicrohttpd openzwave systemd ];

  nativeBuildInputs = [ pkgconfig ];

  # installPhase = ''
  #   runHook preInstall

  #   DESTDIR=$out PREFIX= pkgconfigdir=lib/pkgconfig make install $installFlags

  #   runHook postInstall
  # '';

  enableParallelBuilding = true;

  # buildPhase = ''
    # cd build
    # echo -n "${version}" > version.txt
    # ant -f build.xml setup init  compile dist copy-source-to-build package-linux
  # '';

  # installPhase = ''
    # mkdir -p "$out/share"
    # tar xvf  "ZAP_${version}_Linux.tar.gz" -C "$out/share/"
    # mkdir -p "$out/bin"
    # echo "#!/bin/sh" > "$out/bin/zap"
    # echo \"$out/share/ZAP_${version}/zap.sh\" >> "$out/bin/zap"
    # chmod +x "$out/bin/zap"
  # '';

  meta = with stdenv.lib; {
    homepage = https://www.owasp.org/index.php/ZAP;
    description = "Java application for web penetration testing";
    maintainers = with maintainers; [ mog ];
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}
