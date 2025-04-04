{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  glib-networking,
  gst_all_1,
  libappindicator,
  libayatana-appindicator,
  webkitgtk_4_0,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dorion";
  version = "5.0.1";

  src = fetchurl {
    url = "https://github.com/SpikeHD/Dorion/releases/download/v${finalAttrs.version}/Dorion_${finalAttrs.version}_amd64.deb";
    hash = "sha256-cCZikTZ+IU3mq/FkJfeggXLyWIsWG+a2qu1GbgW93WQ=";
  };

  unpackCmd = ''
    dpkg -X $curSrc .
  '';

  runtimeDependencies = [
    glib-networking
    libappindicator
    libayatana-appindicator
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    webkitgtk_4_0
  ];

  installPhase = ''
    runHook preInstall

    mkdir -pv $out
    mv -v {bin,lib,share} $out

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/SpikeHD/Dorion";
    description = "Tiny alternative Discord client";
    license = lib.licenses.gpl3Only;
    mainProgram = "dorion";
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.intersectLists (lib.platforms.linux) (lib.platforms.x86_64);
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
