{ stdenv, fetchFromGitHub, doxygen, pkgconfig, tree
, udev }:

stdenv.mkDerivation rec {
  name = "openzwave-${version}";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "OpenZWave";
    repo = "open-zwave";
    rev = "V${version}";
    sha256 = "0fbffhm9yaj6w0p9agdqv95808cai2744ckryzhlwk31vznn51si";
  };

  buildInputs = [ udev ];

  nativeBuildInputs = [ doxygen pkgconfig tree ];

  enableParallelBuilding = true;

  preBuild = ''
    export DESTDIR=$out
    export PREFIX=./
  '';

  # We don't just force-remove in case a new version leaves other stuff behind
  # that we need to move out of the way
  postInstall = ''
    mv $out/usr/lib/pkgconfig $out/lib/
    rmdir $out/usr{/lib,}

    substituteInPlace $out/bin/ozw_config \
      --replace /usr/lib $out/lib
  '';

  meta = with stdenv.lib; {
    description = "C++ library to control Z-Wave Networks via a USB Z-Wave Controller";
    homepage    = https://www.openzwave.net;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
