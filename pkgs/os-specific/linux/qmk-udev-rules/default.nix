{ lib, stdenvNoCC, fetchFromGitHub }:

## Usage
# In NixOS, simply add this package to services.udev.packages:
#   services.udev.packages = [ pkgs.qmk-udev-rules ];

stdenvNoCC.mkDerivation rec {
  pname = "qmk-udev-rules";
  version = "0.16.8";

  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = version;
    hash = "sha256-/GI131pvZVyRWJjn3e31l8+m/PjiyKtFzlP5K6xevnw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out/lib/udev/rules.d util/udev/50-qmk.rules
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/qmk/qmk_firmware";
    description = "Official QMK udev rules list";
    platforms = platforms.linux;
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ekleog ];
  };
}
