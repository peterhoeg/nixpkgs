{ stdenv, bash-completion, catch, cmake, fetchFromGitHub, hidapi, pkgconfig }:

stdenv.mkDerivation rec {
  name = "libnitrokey";
  version = "3.1";

  src = fetchFromGitHub {
    owner  = "Nitrokey";
    repo   = "libnitrokey";
    rev    = "v${version}";
    sha256 = "00diqms5y8xs81vxh83znbv1938gx61wvxq3rq62w7m0rlfbn084";
  };

  postPatch = "rm -rf hidapi catch";

  buildInputs = [ hidapi ];

  nativeBuildInputs = [ cmake pkgconfig catch ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DCOMPILE_TESTS=ON"
    "-DCOMPILE_OFFLINE_TESTS=ON"
  ];

  doCheck = true;

  checkPhase = ''
    LD_PRELOAD=./libnitrokey.so:./libcatch.so ctest
  '';

  meta = with stdenv.lib; {
    description = "Communicate with Nitrokey stick devices in a clean and easy manner";
    homepage    = https://nitrokey.com;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ kaiha fpletz ];
  };
}
