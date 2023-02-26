{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, zlib
, libusb1
, enableGUI ? false
, qtbase
}:

mkDerivation rec {
  pname = "heimdall${lib.optionalString enableGUI "-gui"}";
  version = "1.4.2.20210314";

  src = fetchFromGitHub {
    owner = "Benjamin-Dobell";
    repo = "Heimdall";
    # rev = "v${version}";
    rev = "3997d5cc607e6c603c6e7c0d07e42e9868c62af2";
    sha256 = "sha256-QfFbI/oXWUmqx50skcMG0VcQs6aqjYv0hNkKqIgHIq4=";
  };

  buildInputs = [
    zlib
    libusb1
  ] ++ lib.optional enableGUI qtbase;

  nativeBuildInputs = [ cmake pkg-config ];

  NIX_LDFLAGS = "-lusb-1.0";

  cmakeFlags = [
    "-DDISABLE_FRONTEND=${if enableGUI then "OFF" else "ON"}"
    "-DLIBUSB_LIBRARY=${libusb1}"
  ];

  preConfigure = ''
    # Give ownership of the Galaxy S USB device to the logged in user.
    substituteInPlace heimdall/60-heimdall.rules --replace 'MODE="0666"' 'TAG+="uaccess"'
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace libpit/CMakeLists.txt --replace "-std=gnu++11" ""
  '';

  installPhase = lib.optionalString (stdenv.isDarwin && enableGUI) ''
    mkdir -p $out/Applications
    mv bin/heimdall-frontend.app $out/Applications/heimdall-frontend.app
    wrapQtApp $out/Applications/heimdall-frontend.app/Contents/MacOS/heimdall-frontend
  '' + ''
    install -Dm555 -t $out/bin bin/*
    install -Dm444 -t $out/lib/udev/rules.d ../heimdall/60-heimdall.rules
    install -Dm444 ../Linux/README   $out/share/doc/heimdall/README.linux
    install -Dm444 ../OSX/README.txt $out/share/doc/heimdall/README.osx
  '';

  meta = with lib; {
    broken = stdenv.isDarwin;
    homepage = "http://www.glassechidna.com.au/products/heimdall/";
    description = "A cross-platform tool suite to flash firmware onto Samsung Galaxy S devices";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
