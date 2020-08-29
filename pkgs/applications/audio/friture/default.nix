{ lib, fetchFromGitHub, python3Packages, wrapQtAppsHook }:

let
  py = python3Packages;
  relaxedRequirements = [
    "Cython"
    "numpy"
    # "PyOpenGL-accelerate"
    "sounddevice"
    "docutils"
    "appdirs"
  ];

in py.buildPythonApplication rec {
  pname = "friture";
  version = "0.41";

  src = fetchFromGitHub {
    owner = "tlecomte";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-aE0gGnsbSMBM+BwzWx2D/r5CoTQi/IUNIc0olLu6Y/0=";
  };

  # module imports scipy.misc.factorial, but it has been removed since scipy
  # 1.3.0; use scipy.special.factorial instead
  patches = [ ./factorial.patch ];

  postPatch = lib.concatMapStringsSep "\n" (e: ''
    sed -i setup.py -e 's@"${e}==.*"@"${e}"@'
  '') relaxedRequirements;

  nativeBuildInputs = (with py; [ numpy cython scipy ]) ++
    [ wrapQtAppsHook ];

  propagatedBuildInputs = with py; [
    sounddevice
    pyopengl
    docutils
    numpy
    pyqt5
    appdirs
    pyrr
    pyopengl
  ];

  # postFixup = ''
  #   wrapQtApp $out/bin/friture
  #   wrapQtApp $out/bin/.friture-wrapped
  # '';

  meta = with lib; {
    description = "A real-time audio analyzer";
    homepage = "http://friture.org/";
    license = licenses.gpl3;
    platforms = platforms.linux; # fails on Darwin
    maintainers = [ maintainers.laikq ];
  };
}
