{
  stdenv,
  lib,
  fetchurl,
  # native
  cmake,
  desktopToDarwinBundle,
  pkg-config,
  wrapGAppsHook3,
  # not native
  gdal,
  wxGTK32,
  proj,
  libsForQt5,
  curl,
  libiodbc,
  xz,
  libharu,
  opencv,
  vigra,
  pdal,
  libpq,
  unixODBC,
  poppler,
  hdf5,
  netcdf,
  sqlite,
  qhull,
  giflib,
  libsvm,
  fftw,
}:

stdenv.mkDerivation rec {
  pname = "saga";
  version = "9.9.1";

  src = fetchurl {
    url = "mirror://sourceforge/saga-gis/saga-${version}.tar.gz";
    hash = "sha256-InypyVCk08tsByKaIBRFWldwRz1AkNCgFD3DL4OG84w=";
  };

  sourceRoot = "saga-${version}/saga-gis";

  nativeBuildInputs = [
    cmake
    wrapGAppsHook3
    pkg-config
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    curl
    libsForQt5.dxflib
    fftw
    libsvm
    hdf5
    gdal
    wxGTK32
    pdal
    proj
    libharu
    opencv
    vigra
    libpq
    libiodbc
    xz
    qhull
    giflib
  ]
  # See https://groups.google.com/forum/#!topic/nix-devel/h_vSzEJAPXs
  # for why the have additional buildInputs on darwin
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    unixODBC
    poppler
    netcdf
    sqlite
  ];

  cmakeFlags = [
    (lib.cmakeBool "OpenMP_SUPPORT" (!stdenv.hostPlatform.isDarwin))
  ];

  meta = {
    description = "System for Automated Geoscientific Analyses";
    homepage = "https://saga-gis.sourceforge.io";
    changelog = "https://sourceforge.net/p/saga-gis/wiki/Changelog ${version}/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      michelk
      mpickering
    ];
    teams = [ lib.teams.geospatial ];
    platforms = with lib.platforms; unix;
  };
}
