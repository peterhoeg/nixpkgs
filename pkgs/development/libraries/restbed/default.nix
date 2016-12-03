{ stdenv, fetchFromGitHub, cmake, asio, openssl }:

stdenv.mkDerivation rec {
  name = "restbed-${version}";
  version = "4.0";

  src = fetchFromGitHub {
    owner  = "Corvusoft";
    repo   = "restbed";
    rev    = version;
    sha256 = "1dmwhqdjifpgphckph2y86rpd9y30karji129csp3d4nnmgc2whb";
  };

  buildInputs = [cmake asio openssl];

  cmakeFlags = [
    # "-DBUILD_TESTS=YES"
    "-DBUILD_EXAMPLES=NO"
    "-DBUILD_SSL=YES"
    "-DBUILD_SHARED=YES"
  ];

  postInstall = ''
    mv $out/library $out/lib
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "A framework for asynchronous RESTful functionality in C++11 applications";
    license = licenses.agpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ peterhoeg ];
  };
}
