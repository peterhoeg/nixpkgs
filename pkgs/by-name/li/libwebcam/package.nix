{
  lib,
  stdenv,
  fetchurl,
  cmake,
  pkg-config,
  libxml2,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwebcam";
  version = "0.2.5";

  src = fetchurl {
    url = "mirror://sourceforge/project/libwebcam/source/libwebcam-src-${finalAttrs.version}.tar.gz";
    sha256 = "0hcxv8di83fk41zjh0v592qm7c0v37a3m3n3lxavd643gff1k99w";
  };

  patches = [
    ./uvcdynctrl_symlink_support_and_take_data_dir_from_env.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    udevCheckHook
  ];
  buildInputs = [ libxml2 ];

  postPatch = ''
    for f in CMakeLists.txt libwebcam/CMakeLists.txt uvcdynctrl/CMakeLists.txt; do
      substituteInPlace $f \
        --replace-fail 'VERSION 2.6' 'VERSION 3.12'
    done

    substituteInPlace ./uvcdynctrl/CMakeLists.txt \
      --replace-fail "/lib/udev" "$out/lib/udev"

    substituteInPlace ./uvcdynctrl/udev/scripts/uvcdynctrl \
      --replace-fail 'debug=0' 'debug=''${NIX_UVCDYNCTRL_UDEV_DEBUG:-0}' \
      --replace-fail 'uvcdynctrlpath=uvcdynctrl' "uvcdynctrlpath=$out/bin/uvcdynctrl"

    substituteInPlace ./uvcdynctrl/udev/rules/80-uvcdynctrl.rules \
      --replace-fail "/lib/udev" "$out/lib/udev"
  '';

  # preConfigure = ''
  #   cmakeFlagsArray=(
  #     $cmakeFlagsArray
  #     "-DCMAKE_INSTALL_PREFIX=$out"
  #   )
  # '';

  doInstallCheck = true;

  meta = {
    description = "Webcam-tools package";
    platforms = lib.platforms.linux;
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ jraygauthier ];
  };
})
