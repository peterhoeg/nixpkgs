{ stdenv, fetchFromGitHub, cmake, git, boost, qscintilla, qtbase }:

stdenv.mkDerivation rec {
  name = "tora-${version}";
  version = "3.0";

  src = fetchFromGitHub {
    owner  = "tora-tool";
    repo   = "tora";
    rev    = "v${version}";
    sha256 = "0msd10j27axj18cxc4kmwgfr9kn838z2x73c75iv9gcqab1glijq";
  };

  cmakeConfigureFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DWANT_INTERNAL_LOKI=true"
    "-DWANT_INTERNAL_LOKI=true"
  ];

  buildInputs = [ boost cmake git qscintilla qtbase ];

  meta = with stdenv.lib; {
    description = "Tora SQL tool";
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}
