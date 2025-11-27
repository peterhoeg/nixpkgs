{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  libtsm,
  systemdLibs,
  libxkbcommon,
  libdrm,
  libGLU,
  libGL,
  pango,
  pixman,
  pkg-config,
  docbook_xsl,
  libxslt,
  libgbm,
  ninja,
  check,
  shadow,
  buildPackages,
  withGL ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kmscon${lib.optionalString (!withGL) "-no-gl"}";
  version = "9.2.1-unstable-2025-12-24";

  src = fetchFromGitHub {
    owner = "kmscon";
    repo = "kmscon";
    rev = "b95e31363b5cd39137e2a8e247b0e36c66cd4b0a";
    hash = "sha256-wq6W/bi9+cRKMIkQ3kwyUfVYCwUCGtdVB6QEd1C1Ipg=";
  };

  patches = [
    ./sandbox.patch # Generate system units where they should be (nix store) instead of /etc/systemd/system
  ];

  postPatch = ''
    substituteInPlace src/pty.c src/kmscon_conf.c docs/man/kmscon.1.xml.in \
      --replace-fail /bin/login ${lib.getExe' shadow "login"}
  '';

  strictDeps = true;

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  buildInputs = [
    check
    libdrm
    libgbm
    libtsm
    libxkbcommon
    pango
    pixman
    systemdLibs
  ]
  ++ lib.optionals withGL [
    libGL
    libGLU
  ];

  nativeBuildInputs = [
    docbook_xsl
    libxslt # xsltproc
    meson
    ninja
    pkg-config
  ];

  mesonFlags = [
    (lib.mesonEnable "renderer_gltex" withGL)
    (lib.mesonEnable "video_drm3d" withGL)
  ];

  env.NIX_CFLAGS_COMPILE =
    lib.optionalString stdenv.cc.isGNU "-O "
    + "-Wno-error=maybe-uninitialized -Wno-error=unused-result -Wno-error=implicit-function-declaration";

  meta = {
    description = "KMS/DRM based System Console";
    mainProgram = "kmscon";
    homepage = "https://www.freedesktop.org/wiki/Software/kmscon/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
