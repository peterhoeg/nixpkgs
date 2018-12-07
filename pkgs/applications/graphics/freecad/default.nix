{ stdenv, lib, fetchurl, fetchFromGitHub, fetchpatch, cmake, scons, makeWrapper, makeDesktopItem
, coin3d, xercesc, ode, eigen, opencascade, gts, mesa, mesa_glu
, hdf5, vtk, medfile, zlib, python3Packages, swig, gfortran
, soqt, libf2c
, qtbase, qtsvg, qttools, qtwebkit, qtxmlpatterns
, mpi ? null }:

assert mpi != null;

let
  pythonPackages = python3Packages;

in stdenv.mkDerivation rec {
  name = "freecad-${version}";
  version = "0.17";

  src = fetchFromGitHub {
    owner = "FreeCAD";
    repo = "FreeCAD";
    rev = "releases/FreeCAD-${lib.replaceStrings [ "." ] [ "-" ] version}";
    sha256 = "00mdyhrspnaid7ljrdn52ix7s2kapc0v84n4byn0f4xazy6da77n";
  };

  # Their main() removes PYTHONPATH=, and we rely on it.
  postPatch = ''
    sed '/putenv("PYTHONPATH/d' -i src/Main/MainGui.cpp
  '';

  nativeBuildInputs = [ cmake makeWrapper qttools ];

  buildInputs = [
    qtbase qtsvg qtwebkit
    coin3d xercesc ode eigen opencascade gts mesa mesa_glu
    zlib swig gfortran soqt libf2c mpi vtk hdf5 medfile

  ] ++ (with pythonPackages; [
    matplotlib pivy pycollada python boost # pyside2
  ]);

  NIX_LDFLAGS="-L${gfortran.cc}/lib64 -L${gfortran.cc}/lib";

  cmakeFlags = [
    "-DBUILD_QT5=ON"
    "-DBUILD_QT5_WEBKIT=OFF"
    "-DBUILD_START=OFF"
    "-DBUILD_WEB=OFF"
    "-DOpenGL_GL_PREFERENCE=GLVND"
    "-DFREECAD_USE_OCC_VARIANT='Official Version'"
    "-DFREECAD_USE_EXTERNAL_PIVY=ON"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    wrapProgram $out/bin/FreeCAD --prefix PYTHONPATH : $PYTHONPATH \
      --set COIN_GL_NO_CURRENT_CONTEXT_CHECK 1

    mkdir -p $out/share/mime/packages
    cat << EOF > $out/share/mime/packages/freecad.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns='http://www.freedesktop.org/standards/shared-mime-info'>
      <mime-type type="application/x-extension-fcstd">
        <sub-class-of type="application/zip"/>
        <comment>FreeCAD Document</comment>
        <glob pattern="*.fcstd"/>
      </mime-type>
    </mime-info>
    EOF

    mkdir -p $out/share/applications
    cp $desktopItem/share/applications/* $out/share/applications/
    for entry in $out/share/applications/*.desktop; do
      substituteAllInPlace $entry
    done
  '';

  desktopItem = makeDesktopItem {
    name = "freecad";
    desktopName = "FreeCAD";
    genericName = "CAD Application";
    comment = meta.description;
    exec = "@out@/bin/FreeCAD %F";
    categories = "Science;Education;Engineering;";
    startupNotify = "true";
    mimeType = "application/x-extension-fcstd;";
    extraEntries = ''
      Path=@out@/share/freecad
    '';
  };

  meta = with stdenv.lib; {
    description = "General purpose Open Source 3D CAD/MCAD/CAx/CAE/PLM modeler";
    homepage = https://www.freecadweb.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ viric ];
    platforms = platforms.linux;
  };
}
