{ stdenv, fetchFromGitHub, cmake, pkgconfig
, boost, cryptopp, curl, fuse, openssl, python
}:

stdenv.mkDerivation rec {
  pname = "cryfs";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner  = "cryfs";
    repo   = "cryfs";
    rev    = "${version}";
    sha256 = "1mi6lf8k4bknxjf11a2vqsrgyx3ld8fbsqssvs91dlmwcpm9qi1i";
  };

  postPatch = ''
    patchShebangs src

    sed -i CMakeLists.txt \
      -e '10ifind_package(CryptoPP REQUIRED)' \
      -e '11itarget_link_libraries(cryfs cryptopp-shared)

    sed -i test/CMakeLists.txt \
      -e '/fspp/d' \
      -e '/cryfs-cli/d

    rm -rf vendor/{cryptopp,spdlog/spdlog}
  '';

  # upstream only supports building with the vendored libs:
  # https://github.com/cryfs/cryfs/issues/275#issuecomment-495964761
  # It would be very nice if somebody tried to see if we could compile against the
  # various libraries we already have in nixpkgs
  buildInputs = [ boost cryptopp curl fuse openssl python ];

  patches = [
    ./test-no-network.patch  # Disable tests using external networking
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DBUILD_TESTING=ON"
    "-DCRYFS_UPDATE_CHECKS=OFF"
    "-DBoost_USE_STATIC_LIBS=OFF" # this option is case sensitive
  ];

  # Tests are broken on darwin
  doCheck = !stdenv.isDarwin;


  #SKIP_IMPURE_TESTS="CMakeFiles|fspp|cryfs-cli"

  meta = with stdenv.lib; {
    description = "Cryptographic filesystem for the cloud";
    homepage    = https://www.cryfs.org;
    license     = licenses.lgpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = with platforms; linux;
  };
}
