{ stdenv, lib, fetchurl, cmake, llvmPackages, buildPythonPackage, qt5 }: #pysideGeneratorrunner, pysideShiboken, qtbase }:

# This derivation provides a Python module and should therefore be called via `python-packages.nix`.
buildPythonPackage rec {
  pname = "pyside2";
  version = "5.11.2";

  src = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-${version}-src/pyside-setup-everywhere-src-${version}.tar.xz";
    sha256 = "1hl6rf60gyp4wv3djp5yihm0yib7n6xcmz1h7l47dr1jz3qp5x8q";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = with llvmPackages; [ cmake clang-unwrapped llvm ]; #pysideGeneratorrunner pysideShiboken qt4 ];

  propagatedBuildInputs = with qt5; [ qtbase qtxmlpatterns ];

  # makeFlags = "QT_PLUGIN_PATH=" + pysideShiboken + "/lib/generatorrunner";

  meta = with lib; {
    description = "LGPL-licensed Python bindings for the Qt cross-platform application and UI framework";
    license = licenses.lgpl21;
    homepage = http://www.pyside.org;
    maintainers = with maintainers; [ chaoflow ];
  };
}
