{ stdenv, lib, fetchurl, fetchFromGitHub, unzip, kernel, utillinux, libdrm, libusb1, makeWrapper }:

let
  arch =
    if stdenv.system == "x86_64-linux" then "x64"
    else if stdenv.system == "i686-linux" then "x86"
    else throw "Unsupported architecture";
  libPath = lib.makeLibraryPath [ stdenv.cc.cc utillinux libusb1 ];
  evdiVersion = "1.4.1";
  ubuntuVersion = "1604";

in stdenv.mkDerivation rec {
  name = "displaylink-${version}";
  version = "1.3.52";

  src = fetchFromGitHub {
    owner  = "DisplayLink";
    repo   = "evdi";
    rev    = "v${evdiVersion}";
    sha256 = "176cq83qlmhc4c00dwfnqgd021l7s4gyj8604m5zmxbz0r5mnawv";
  };

  daemon = fetchurl {
    name   = "displaylink.zip";
    url    = "http://www.displaylink.com/downloads/file?id=744";
    sha256 = "0ridpsxcf761vym0nlpq702qa46ynddzci17bjmyax2pph7khr0k";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  buildInputs = [ kernel libdrm ];

  buildCommand = ''
    unpackPhase
    cd $sourceRoot
    unzip $daemon
    chmod +x displaylink-driver-${version}.run
    ./displaylink-driver-${version}.run --target daemon --noexec

    ( cd module
      export makeFlags="$makeFlags KVER=${kernel.modDirVersion} KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      export hardeningDisable="pic format"
      buildPhase
      install -Dm755 evdi.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/gpu/drm/evdi/evdi.ko
    )

    ( cd library
      buildPhase
      install -Dm755 libevdi.so $out/lib/libevdi.so
    )

    fixupPhase

    ( cd daemon
      install -Dt $out/lib/displaylink *.spkg
      install -Dm755 ${arch}-ubuntu-${ubuntuVersion}/DisplayLinkManager $out/bin/DisplayLinkManager
      patchelf \
        --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) \
        --set-rpath $out/lib:${libPath} \
        $out/bin/DisplayLinkManager
      wrapProgram $out/bin/DisplayLinkManager \
        --run "cd $out/lib/displaylink"
    )
  '';

  meta = with stdenv.lib; {
    description = "DisplayLink DL-5xxx, DL-41xx and DL-3x00 Driver for Linux";
    homepage = http://www.displaylink.com/;
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
