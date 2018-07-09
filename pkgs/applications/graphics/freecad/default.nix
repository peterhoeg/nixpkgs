{ stdenv, fetchgit, cmake, makeWrapper, makeDesktopItem
, qtbase, qtsvg, qttools, qtwebkit
, coin3d, xercesc, ode, eigen, opencascade, gts, libGLU_combined
, hdf5, vtk, medfile, boost, zlib, python3Packages, swig, gfortran, fetchpatch
, soqt, libf2c
, mpi ? null }:

assert mpi != null;

let
  pythonPackages = python3Packages;

in stdenv.mkDerivation rec {
  name = "freecad-${version}";
  version = "0.17.20180508";

  # Upstream makes changes to release branches without cutting new releases
  src = fetchgit {
    url = "https://github.com/FreeCAD/FreeCAD.git";
    branchName = "releases/FreeCAD-${stdenv.lib.replaceStrings [ "." ] [ "-" ] version}";
    sha256 = "1qyamxqc26w6zicdgd7cis1c2jh0mvw28d8m5glgqpyagig0nkbj";
  };

  patches = [
  (fetchpatch {
  url = "https://github.com/FreeCAD/FreeCAD/pull/1523.patch";
    sha256 = "0yglbws2xvmb3c18xajcw47dysz4fcdrpphvz4h4q2x6wx8q43gj";
})
];

  postPatch = ''
    cat <<_EOF >src/Tools/SubWCRev.py
    #!${pythonPackages.python.interpreter}
    print('${version}')
    _EOF
  '';

  nativeBuildInputs = [ cmake makeWrapper qttools ];

  buildInputs = [
    qtbase qtsvg qtwebkit
    coin3d xercesc ode eigen opencascade gts libGLU_combined
    zlib swig gfortran soqt libf2c mpi vtk hdf5 medfile
  ] ++ (with pythonPackages; [
    matplotlib pycollada pyside pysideShiboken pysideTools python boost # pivy
  ]);

  # This should work on both x86_64, and i686 linux
  NIX_LDFLAGS = [
    "-L${gfortran.cc}/lib64"
    "-L${gfortran.cc}/lib"
  ];

  # Their main() removes PYTHONPATH=, and we rely on it.
  preConfigure = ''
    sed '/putenv("PYTHONPATH/d' -i src/Main/MainGui.cpp
  '';

  cmakeFlags = [
    "-DBUILD_QT5=ON"
    "-DBOOST_INCLUDEDIR=${pythonPackages.boost.dev}/include"
    "-DBOOST_LIBRARYDIR=${pythonPackages.boost}/lib"
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

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
