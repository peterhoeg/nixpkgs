{ stdenv, lib, fetchFromGitHub, cmake }:

let
  version = "8.2.0";
  rev = "CRYPTOPP_${lib.replaceStrings [ "." ] [ "_" ] version}";

  # Build via cmake which adds support for downstream consumers to use cmake
  # as well
  cmakeFiles = fetchFromGitHub {
    owner = "noloader";
    repo = "cryptopp-cmake";
    inherit rev;
    sha256 = "10ln100055nxb38dk6v2vn737drxkly44lq699k0l6qc2ikbdiwa";
  };

in stdenv.mkDerivation rec {
  pname = "crypto++";
  inherit version;

  src = fetchFromGitHub {
    owner = "weidai11";
    repo = "cryptopp";
    inherit rev;
    sha256 = "01zrrzjn14yhkb9fzzl57vmh7ig9a6n6fka45f8za0gf7jpcq3mj";
  };

  postPatch = ''
    cp ${cmakeFiles}/{CMakeLists.txt,cryptopp-config.cmake} .
  '';

  nativeBuildInputs = [ cmake ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    
    LD_LIBRARY_PATH=`pwd` make test

    runHook postCheck
  '';

  meta = with stdenv.lib; {
    description = "Crypto++, a free C++ class library of cryptographic schemes";
    homepage = http://cryptopp.com/;
    license = licenses.boost;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
