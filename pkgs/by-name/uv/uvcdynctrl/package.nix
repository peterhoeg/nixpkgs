{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libxml2,
  udevCheckHook,
}:

stdenv.mkDerivation {
  version = "0.3.0";
  pname = "uvcdynctrl";

  src = fetchFromGitHub {
    owner = "cshorler";
    repo = "webcam-tools";
    rev = "bee2ef3c9e350fd859f08cd0e6745871e5f55cb9";
    sha256 = "0s15xxgdx8lnka7vi8llbf6b0j4rhbjl6yp0qxaihysf890xj73s";
  };

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

    local fixup_list=(
      uvcdynctrl/CMakeLists.txt
      uvcdynctrl/udev/rules/80-uvcdynctrl.rules
      uvcdynctrl/udev/scripts/uvcdynctrl
    )
    for f in "''${fixup_list[@]}"; do
      substituteInPlace "$f" \
        --replace-warn "/etc/udev" "$out/etc/udev" \
        --replace-warn "/lib/udev" "$out/lib/udev"
    done
  '';

  doInstallCheck = true;

  meta = {
    description = "Simple interface for devices supported by the linux UVC driver";
    homepage = "https://guvcview.sourceforge.net";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ puffnfresh ];
    platforms = lib.platforms.linux;
    mainProgram = "uvcdynctrl";
  };
}
