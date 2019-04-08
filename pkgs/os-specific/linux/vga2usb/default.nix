{ stdenv, fetchurl, kernel, kmod, cpio, rpm, tree }:

let
  kernelVersion = "4.14.13-300";

in stdenv.mkDerivation rec {
  name = "vga2usb-${version}";
  version = "3.30.2.11";

  src = fetchurl {
    url = "https://ssl.epiphan.com/downloads/linux/browse.php?dir=dists%2Ffedora%2F27%2Fx86_64&file=${name}-fedora-${kernelVersion}.fc27.x86_64-x86_64.rpm";
    sha256 = "0kqzzivkhvi9bsfs3w7f9kcdhq41gz8ibqpzasf2mcdjw16m59cy";
    name = "vga2usb-${version}-fedora-${kernelVersion}-x86_64.rpm";
  };

  patches = [ ./do_not_remove.patch ];

  postPatch = ''
    substituteInPlace Config.mak \
      --replace /lib/modules $out/lib/modules

      echo $src
  '';

  sourceRoot = "usr/src/${name}";

  nativeBuildInputs = [ kernel.moduleBuildDependencies cpio rpm tree ];

  buildInputs = [ kernel kmod ];

  makeFlags = [
    # "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  unpackPhase = "rpm2cpio $src | cpio -idmv";

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
