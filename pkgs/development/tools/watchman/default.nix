{ stdenv
, lib
, fetchFromGitHub
, cmake
, glog
, gtest
, pkg-config
, python3
, boost
, fmt
, folly
, libevent
, openssl
, pcre
, withApple ? stdenv.isDarwin
, CoreServices

, cargo
}:

stdenv.mkDerivation rec {
  pname = "watchman";
  version = "2022.03.07.00";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "watchman";
    rev = "v${version}";
    hash = "sha256-0a3tWCNTIhGKgv47gwTlR2bsn0qusbiiHX8tmKRkzgQ=";
  };

  nativeBuildInputs = [
    cargo
    cmake
    glog
    gtest
    pkg-config
    python3
  ];

  buildInputs = [
    boost
    fmt
    folly
    libevent
    pcre
    openssl
  ]
  ++ lib.optionals withApple [ CoreServices ];

  cmakeFlags = [
    "-Wno-dev"
    "-DENABLE_EDEN_SUPPORT=OFF"
    "-DWATCHMAN_STATE_DIR=/run/watchman"
    "-DINSTALL_WATCHMAN_STATE_DIR=OFF"
  ];

  WATCHMAN_VERSION_OVERRIDE = version;

  meta = with lib; {
    description = "Watches files and takes action when they change";
    homepage = "https://facebook.github.io/watchman";
    license = licenses.asl20;
    maintainers = with maintainers; [ cstrahan ];
    platforms = with platforms; linux ++ darwin;
  };
}
