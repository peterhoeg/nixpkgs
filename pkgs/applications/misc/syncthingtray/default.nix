{
  lib,
  stdenv,
  fetchFromGitHub,
  qtbase,
  qtsvg,
  qtwayland,
  qtwebengine,
  qtdeclarative,
  extra-cmake-modules,
  cpp-utilities,
  qtutilities,
  qtforkawesome,
  boost,
  wrapQtAppsHook,
  cmake,
  pkg-config,
  kio,
  plasma-framework,
  qttools,
  iconv,
  cppunit,
  syncthing,
  xdg-utils,
  webviewSupport ? true,
  jsSupport ? true,
  kioPluginSupport ? stdenv.hostPlatform.isLinux,
  plasmoidSupport ? stdenv.hostPlatform.isLinux,
  systemdSupport ? stdenv.hostPlatform.isLinux,
  /*
    It is possible to set via this option an absolute exec path that will be
    written to the `~/.config/autostart/syncthingtray.desktop` file generated
    during runtime. Alternatively, one can edit the desktop file themselves after
    it is generated See:
    https://github.com/NixOS/nixpkgs/issues/199596#issuecomment-1310136382
  */
  autostartExecPath ? "syncthingtray",
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  version = "2.0.6";
  pname = "syncthingtray";

  src = fetchFromGitHub {
    owner = "Martchus";
    repo = "syncthingtray";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ie4NCeOsVEXzg0qM06D5dZhtwx3UT9BghH4fP0B9oIY=";
  };

  buildInputs = [
    qtbase
    qtsvg
    cpp-utilities
    qtutilities
    boost
    qtforkawesome
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ iconv ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ qtwayland ]
  ++ lib.optionals webviewSupport [ qtwebengine ]
  ++ lib.optionals jsSupport [ qtdeclarative ]
  ++ lib.optionals kioPluginSupport [ kio ]
  ++ lib.optionals plasmoidSupport [ plasma-framework ];

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
    pkg-config
    qttools
    # Although these are test dependencies, we add them anyway so that we test
    # whether the test units compile. On Darwin we don't run the tests but we
    # still build them.
    cppunit
    syncthing
  ]
  ++ lib.optionals plasmoidSupport [ extra-cmake-modules ];

  # syncthing server seems to hang on darwin, causing tests to fail.
  doCheck = !stdenv.hostPlatform.isDarwin;
  preCheck = ''
    export QT_QPA_PLATFORM=offscreen
    export QT_PLUGIN_PATH="${lib.getBin qtbase}/${qtbase.qtPluginPrefix}"
  '';
  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # put the app bundle into the proper place /Applications instead of /bin
    mkdir -p $out/Applications
    mv $out/bin/syncthingtray.app $out/Applications
    # Make binary available in PATH like on other platforms
    ln -s $out/Applications/syncthingtray.app/Contents/MacOS/syncthingtray $out/bin/syncthingtray
  '';
  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  cmakeFlags = [
    (lib.cmakeFeature "QT_PACKAGE_PREFIX" "Qt${lib.versions.major qtbase.version}")
    (lib.cmakeFeature "KF_PACKAGE_PREFIX" "KF${lib.versions.major qtbase.version}")
    (lib.cmakeBool "BUILD_TESTING" true)
    # See https://github.com/Martchus/syncthingtray/issues/208
    (lib.cmakeBool "EXCLUDE_TESTS_FROM_ALL" false)
    (lib.cmakeFeature "AUTOSTART_EXEC_PATH" autostartExecPath)
    # See https://github.com/Martchus/syncthingtray/issues/42
    (lib.cmakeFeature "QT_PLUGIN_DIR" "${placeholder "out"}/${qtbase.qtPluginPrefix}")
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "SYSTEMD_SUPPORT" systemdSupport)
    (lib.cmakeBool "NO_PLASMOID" (!plasmoidSupport))
    (lib.cmakeBool "NO_FILE_ITEM_ACTION_PLUGIN" (!kioPluginSupport))
  ]
  ++ lib.optionals (!webviewSupport) [ (lib.cmakeFeature "WEBVIEW_PROVIDER" "none") ];

  env.LANG = "C.UTF-8";

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ xdg-utils ]}"
  ];

  meta = {
    homepage = "https://github.com/Martchus/syncthingtray";
    description = "Tray application and Dolphin/Plasma integration for Syncthing";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "syncthingtray";
  };
})
