{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,

  cmake,
  qttools,
  wrapQtAppsHook,

  curl,
  ffmpeg,
  libmediainfo,
  libzen,
  qt5compat ? null, # qt6 only
  qtbase,
  qtdeclarative,
  qtmultimedia,
  qtsvg,
  qtwayland,
  quazip,
}:

let
  qtVersion = lib.versions.major qtbase.version;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mediaelch";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "Komet";
    repo = "MediaElch";
    rev = "v${finalAttrs.version}";
    hash = "sha256-m2d4lnyD8HhhqovMdeG36dMK+4kJA7rlPHE2tlhfevo=";
    fetchSubmodules = true;
  };

  patches = lib.optionals (finalAttrs.version == "2.12.0" && qtVersion == "6") [
    (fetchpatch {
      url = "https://github.com/Komet/MediaElch/pull/1878/commits/89ebf98dd13c365ce7ffaaece6fdd3329cf62c9f.patch";
      hash = "sha256-Lv6rvjKbRNr5XrdZhPyw4S4RRCOnfAGhWgcSLo0gqS8=";
    })
  ];

  nativeBuildInputs = [
    cmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs =
    [
      curl
      ffmpeg
      libmediainfo
      libzen
      qtbase
      qtdeclarative
      qtmultimedia
      qtsvg
      qtwayland
      quazip
    ]
    ++ lib.optionals (qtVersion == "6") [
      qt5compat
    ];

  cmakeFlags = [
    (lib.cmakeBool "DISABLE_UPDATER" true)
    (lib.cmakeBool "USE_EXTERN_QUAZIP" true)
    (lib.cmakeBool "MEDIAELCH_FORCE_QT${qtVersion}" true)
  ];

  # libmediainfo.so.0 is loaded dynamically
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${libmediainfo}/lib"
  ];

  meta = with lib; {
    homepage = "https://mediaelch.de/mediaelch/";
    description = "Media Manager for Kodi";
    mainProgram = "MediaElch";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ stunkymonkey ];
    platforms = platforms.linux;
  };
})
