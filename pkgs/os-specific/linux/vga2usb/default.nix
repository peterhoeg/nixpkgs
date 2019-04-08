{ stdenv, fetchurl, kernel, kmod, dpkg, tree }:

let
  kernelVersion = "4.9.30";

in stdenv.mkDerivation rec {
  name = "vga2usb-${version}";
  version = "3.30.2.11";

  src = fetchurl {
    url = "https://ssl.epiphan.com/downloads/linux/browse.php?dir=dists%2Fdebian%2F9.0%2Fx86_64&file=vga2usb-${version}-debian-${kernelVersion}-x86_64.deb";
    sha256 = "17wi8zykfkqjrb3wpq6hnwzw88x30pv9i1yl6fr55gpvrr5p736h";
    name = "vga2usb-${version}-debian-${kernelVersion}-x86_64.deb";
  };

  patches = [ ./do_not_remove.patch ];

  postPatch = ''
    substituteInPlace Config.mak \
      --replace /lib/modules $out/lib/modules
  '';

  sourceRoot = "usr/src/${name}";

  nativeBuildInputs = [ kernel.moduleBuildDependencies dpkg tree ];

  buildInputs = [ kernel kmod ];

  makeFlags = [
    # "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  unpackPhase = "dpkg -x $src .";

  hardeningDisable = [ "format" "pic" "fortify" ];

  preBuild = "src=.";

  installPhase = ''
    runHook preInstall

    install -Dm755 vga2usb.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/vga2usb/vga2usb.ko

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Extensible Virtual Display Interface";
    platforms = platforms.linux;
    license = with licenses; [ lgpl21 gpl2 ];
    homepage = https://www.displaylink.com/;
  };
}
