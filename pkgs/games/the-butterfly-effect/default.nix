{ stdenv, fetchFromGitHub, cmake, gettext
, box2d, qtbase, qtsvg, qttools, qttranslations }:

stdenv.mkDerivation rec {
  name = "tbe-${version}";
  version = "0.9.3.1";

  src = fetchFromGitHub {
    owner  = "kaa-ching";
    repo   = "tbe";
    rev    = "v${version}";
    sha256 = "1ag2cp346f9bz9qy6za6q54id44d2ypvkyhvnjha14qzzapwaysj";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace /usr     $out \
      --replace 'games)' 'bin)'
  '';

  buildInputs = [
    box2d
    qtbase qtsvg qttranslations
  ];

  nativeBuildInputs = [ cmake gettext qttools ];

  meta = with stdenv.lib; {
    description = "A physics-based game vaguely similar to Incredible Machine";
    homepage = http://the-butterfly-effect.org/;
    maintainers = with maintainers; [ raskin ];
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
