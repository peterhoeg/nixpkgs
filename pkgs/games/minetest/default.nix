{ lib
, stdenv
, fetchFromGitHub
, gitUpdater
, cmake
, irrlichtmt
, coreutils
, libpng
, bzip2
, curl
, libogg
, jsoncpp
, libjpeg
, libGLU
, openal
, libvorbis
, sqlite
, luajit
, freetype
, gettext
, doxygen
, ncurses
, graphviz
, xorg
, gmp
, libspatialindex
, leveldb
, postgresql
, hiredis
, libiconv
, zlib
, ninja
, prometheus-cpp
, mesa
, OpenGL
, OpenAL ? openal
, Carbon
, Cocoa
, withTouchSupport ? false
, buildClient ? true
, buildServer ? true
}:

let
  inherit (lib)
    cmakeBool cmakeFeature
    optionals optionalString;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "minetest";
  version = "5.8.0";

  src = fetchFromGitHub {
    owner = "minetest";
    repo = "minetest";
    rev = finalAttrs.version;
    hash = "sha256-Oct8nQORSH8PjYs+gHU9QrKObMfapjAlGvycj+AJnOs=";
  };

  cmakeFlags = [
    (cmakeBool "BUILD_CLIENT" buildClient)
    (cmakeBool "BUILD_SERVER" buildServer)
    (cmakeBool "BUILD_UNITTESTS" (finalAttrs.doCheck or false))
    (cmakeBool "ENABLE_PROMETHEUS" buildServer)
    (cmakeBool "ENABLE_TOUCH" withTouchSupport)
    # Ensure we use system libraries
    (cmakeBool "ENABLE_SYSTEM_GMP" true)
    (cmakeBool "ENABLE_SYSTEM_JSONCPP" true)
    # Updates are handled by nix anyway
    (cmakeBool "ENABLE_UPDATE_CHECKER" false)
    # ...but make it clear that this is a nix package
    (cmakeFeature "VERSION_EXTRA" "NixOS")

    # Remove when https://github.com/NixOS/nixpkgs/issues/144170 is fixed
    (cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (cmakeFeature "CMAKE_INSTALL_DATADIR" "share")
    (cmakeFeature "CMAKE_INSTALL_DOCDIR" "share/doc/minetest")
    (cmakeFeature "CMAKE_INSTALL_MANDIR" "share/man")
    (cmakeFeature "CMAKE_INSTALL_LOCALEDIR" "share/locale")

  ];

  nativeBuildInputs = [
    cmake
    doxygen
    graphviz
    ninja
  ];

  buildInputs = [
    bzip2
    curl
    freetype
    gettext
    gmp
    irrlichtmt
    jsoncpp
    libspatialindex
    ncurses
    sqlite
    zlib
  ] ++ optionals (lib.meta.availableOn stdenv.hostPlatform luajit) [ luajit ]
    ++ optionals stdenv.hostPlatform.isDarwin [
    Carbon
    Cocoa
    OpenAL
    OpenGL
    libiconv
    mesa # for <KHR/khrplatform.h>
  ] ++ optionals buildClient [
    libGLU
    libjpeg
    libogg
    libpng
    libvorbis
    openal
  ] ++ optionals (buildClient && !stdenv.hostPlatform.isDarwin) [
    xorg.libX11
  ] ++ optionals buildServer [
    hiredis
    leveldb
    postgresql
    prometheus-cpp
  ];

  postPatch = ''
    substituteInPlace src/filesys.cpp --replace-fail "/bin/rm" "${coreutils}/bin/rm"
  '' + optionalString stdenv.isDarwin ''
    sed -i '/pagezero_size/d;/fixup_bundle/d' src/CMakeLists.txt
  '';

  postInstall = optionalString stdenv.isLinux ''
    patchShebangs $out
  '' + optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv $out/minetest.app $out/Applications
  '';

  passthru.updateScript = gitUpdater {
    allowedVersions = "\\.";
    ignoredVersions = "-android$";
  };

  meta = with lib; {
    homepage = "https://minetest.net/";
    description = "Infinite-world block sandbox game";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ pyrolagus fpletz fgaz ];
    mainProgram = "minetest${optionalString buildServer "server"}";
  };
})
