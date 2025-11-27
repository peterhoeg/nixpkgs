{
  lib,
  stdenv,
  fetchFromGitHub,
  libxkbcommon,
  pkg-config,
  meson,
  ninja,
  check,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtsm";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "kmscon";
    repo = "libtsm";
    tag = "v" + finalAttrs.version;
    hash = "sha256-xAMQOACyXfh3HhsX44mzGBsR6vqjv0uTRwc5ePfPPls=";
  };

  buildInputs = [ libxkbcommon ];

  nativeBuildInputs = [
    check
    meson
    ninja
    pkg-config
  ];

  meta = {
    description = "Terminal-emulator State Machine";
    homepage = "https://www.freedesktop.org/wiki/Software/kmscon/libtsm/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
