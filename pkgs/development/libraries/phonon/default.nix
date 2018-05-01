{ stdenv, lib, fetchurl, cmake, pkgconfig, extra-cmake-modules
, qtbase, qttools
, libGLU_combined, libpulseaudio }:

with lib;

let
  v = "4.9.1";

  soname = "phonon4qt5";
  buildsystemdir = "share/cmake/${soname}";

in stdenv.mkDerivation rec {
  name = "phonon-${v}";

  src = fetchurl {
    url = "mirror://kde/stable/phonon/${v}/phonon-${v}.tar.xz";
    sha256 = "177647r2jqfm32hqcz2nqfqv6v48hn5ab2vc31svba2wz23fkgk7";
  };

  buildInputs = [
    libGLU_combined libpulseaudio
    qtbase qttools
  ];

  nativeBuildInputs = [ cmake pkgconfig extra-cmake-modules ];

  outputs = [ "out" "dev" ];

  NIX_CFLAGS_COMPILE = "-fPIC";

  cmakeFlags = [ "-DPHONON_BUILD_PHONON4QT5=ON" ];

  preConfigure = ''
    cmakeFlags+=" -DPHONON_QT_MKSPECS_INSTALL_DIR=''${!outputDev}/mkspecs"
    cmakeFlags+=" -DPHONON_QT_IMPORTS_INSTALL_DIR=''${!outputBin}/$qtQmlPrefix"
    cmakeFlags+=" -DPHONON_QT_PLUGIN_INSTALL_DIR=''${!outputBin}/$qtPluginPrefix/designer"
  '';

  postPatch = ''
    sed -i PhononConfig.cmake.in \
        -e "/get_filename_component(rootDir/ s/^.*$//" \
        -e "/^set(PHONON_INCLUDE_DIR/ s|\''${rootDir}/||" \
        -e "/^set(PHONON_LIBRARY_DIR/ s|\''${rootDir}/||" \
        -e "/^set(PHONON_BUILDSYSTEM_DIR/ s|\''${rootDir}|''${!outputDev}|"

    sed -i cmake/FindPhononInternal.cmake \
        -e "/set(INCLUDE_INSTALL_DIR/ c set(INCLUDE_INSTALL_DIR \"''${!outputDev}/include\")"

    sed -i cmake/FindPhononInternal.cmake \
        -e "/set(PLUGIN_INSTALL_DIR/ c set(PLUGIN_INSTALL_DIR \"$qtPluginPrefix/..\")"

    sed -i CMakeLists.txt \
        -e "/set(BUILDSYSTEM_INSTALL_DIR/ c set(BUILDSYSTEM_INSTALL_DIR \"''${!outputDev}/${buildsystemdir}\")"
  '';

  postFixup = ''
    sed -i "''${!outputDev}/lib/pkgconfig/${soname}.pc" \
        -e "/^exec_prefix=/ c exec_prefix=''${!outputBin}/bin"
  '';

  meta = with stdenv.lib; {
    description = "Multimedia API for Qt";
    homepage = https://phonon.kde.org/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [ ttuegel ];
    platforms = platforms.linux;
  };

}
