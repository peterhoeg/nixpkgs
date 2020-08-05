{ stdenv
, fetchFromGitHub
, autoreconfHook
, libtsm
, systemd
, libxkbcommon
, libdrm
, libGLU, libGL
, pango
, pixman
, pkgconfig
, docbook_xsl
, libxslt
}:

stdenv.mkDerivation rec {
  pname = "kmscon";
  version = "unstable-2019-11-06";

  src = fetchFromGitHub {
    owner = "CarlosNihelton";
    repo = "kmscon";
    rev = "3e15a2df50e82b540e0b5155ab9f90675b1bf790";
    sha256 = "sha256-WHP27jAQN5wYmuZ7deT6ETV4Gk16TEkr47r/hdm5fI4=";
  };

  buildInputs = [
    libGLU libGL
    libdrm
    libtsm
    libxkbcommon
    libxslt
    pango
    pixman
    systemd
  ];

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    pkgconfig
  ];

  configureFlags = [
    "--disable-debug"
    "--enable-multi-seat"
    "--enable-optimizations"
    "--with-renderers=bbulk,gltex,pixman"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "KMS/DRM based System Console";
    homepage = "http://www.freedesktop.org/wiki/Software/kmscon/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
