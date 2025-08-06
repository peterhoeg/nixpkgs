{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libGLU,
  libGL,
  libglut,

  GLPreference ? "LEGACY", # LEGACY to retain existing behaviour
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bullet";
  version = "3.25";

  src = fetchFromGitHub {
    owner = "bulletphysics";
    repo = "bullet3";
    tag = finalAttrs.finalPackage.version;
    hash = "sha256-AGP05GoxLjHqlnW63/KkZe+TjO3IKcgBi+Qb/osQuCM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libGLU
    libGL
    libglut
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "BUILD_CPU_DEMOS" false)
    (lib.cmakeBool "INSTALL_EXTRA_LIBS" true)
    (lib.cmakeFeature "OpenGL_GL_PREFERENCE" GLPreference)
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.cmakeBool "BUILD_BULLET2_DEMOS" false)
    (lib.cmakeBool "BUILD_UNIT_TESTS" false)
    (lib.cmakeBool "BUILD_BULLET_ROBOTICS_GUI_EXTRA" false)
  ];

  env.NIX_CFLAGS_COMPILE =
    if stdenv.cc.isClang then
      "-Wno-error=argument-outside-range -Wno-error=c++11-narrowing"
    else
      "-Wno-narrowing"; # needed for examples/ThirdPartyLibs/Gwen/CMakeLists.txt

  meta = {
    description = "Professional free 3D Game Multiphysics Library";
    longDescription = ''
      Bullet 3D Game Multiphysics Library provides state of the art collision
      detection, soft body and rigid body dynamics.
    '';
    homepage = "https://bulletphysics.org";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ aforemny ];
    platforms = lib.platforms.unix;
  };
})
