{ stdenv, fetchFromGitHub, doxygen, pkgconfig, which
, udev, libmicrohttpd }:

let
  open-zwave = stdenv.mkDerivation rec {
    name = "open-zwave";
    version = "20180331";

    src = fetchFromGitHub {
      owner = "OpenZWave";
      repo = "open-zwave";
      rev = "5bdd857f875c87e2cfe269b2b1c9a1c970149091";
      sha256 = "1sws7n1xszzk3g3gx3vz2m65zai2l6kcvb0zv0n780k036pn0l82";
    };

    postPatch = ''
      substituteInPlace Makefile \
        --replace /usr/local $out
    '';

    buildInputs = [ udev ];

    nativeBuildInputs = [ doxygen pkgconfig which ];

    makeFlags = [
      "DESTDIR=$(out)"
      "PREFIX=/"
    ];

    enableParallelBuilding = true;
  };


in stdenv.mkDerivation rec {
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
      --replace '-framework IOKit -framework CoreFoundation' '-ludev'
  '';

  buildInputs = [ udev open-zwave libmicrohttpd ];

  nativeBuildInputs = [ pkgconfig ];

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
