{ stdenv, fetchFromGitHub, cmake, libsodium, ncurses, libopus, libmsgpack
, libvpx, check, libconfig, pkgconfig }:

stdenv.mkDerivation rec {
  name = "libtoxcore-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner  = "TokTok";
    repo   = "c-toxcore";
    rev    = "v${version}";
    sha256 = "19h3hqsnaj0xniy7id8m95fgrsl01rv7rmipidnfyj99svpb190l";
  };

  cmakeFlags = [
    "-DDHT_BOOTSTRAP=ON"
    "-DBOOTSTRAP_DAEMON=ON"
  ];

  buildInputs = [
    libsodium libmsgpack ncurses libconfig
  ] ++ stdenv.lib.optionals (!stdenv.isArm) [
    libopus libvpx
  ];

  nativeBuildInputs = [ check cmake pkgconfig ];

  enableParallelBuilding = true;

  checkPhase = "ctest";

  # first 2 tests are OK but the 3rd (bootstrap) just hangs as I'm guessing it's
  # trying to actually bootstrap itself
  doCheck = false;

  meta = with stdenv.lib; {
    description = "P2P FOSS instant messaging application aimed to replace Skype";
    homepage = https://tox.chat;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.all;
  };
}
