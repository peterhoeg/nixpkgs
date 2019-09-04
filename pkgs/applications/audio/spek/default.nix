{ stdenv, fetchFromGitHub, autoreconfHook, intltool, pkgconfig
, ffmpeg, wxGTK }:

stdenv.mkDerivation rec {
  pname = "spek";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "alexkay";
    repo = pname;
    rev = "v${version}";
    sha256 = "0y4hlhswpqkqpsglrhg5xbfy1a6f9fvasgdf336vhwcjqsc3k2xv";
  };

  nativeBuildInputs = [ autoreconfHook intltool pkgconfig ];

  buildInputs = [ ffmpeg wxGTK ];

  AUTOPOINT = "intltoolize --automake --copy";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Analyse your audio files by showing their spectrogram";
    homepage = "http://spek.cc/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bjornfor ];
    platforms = platforms.all;
  };
}
