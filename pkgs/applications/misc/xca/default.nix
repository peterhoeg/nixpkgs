{ mkDerivation
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libtool
, openssl
, qttools
}:

mkDerivation rec {
  pname = "xca";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "chris2511";
    repo = "xca";
    rev = "RELEASE.${version}";
    sha256 = "sha256-k9/JyN7E0p8lRSY/4W7CxJ9wAuSVRbLituL4rGWt4BM=";
  };

  # we need this after the configure stage which creates an invalid version as
  # we don't have a proper checkout
  preBuild = ''
    echo '#define XCA_VERSION "${version}"' > local.h
  '';

  # TODO: check in version > 2.4.0 if still needed
  NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
    "-Wno-error=deprecated-declarations"
    "-Wno-error=maybe-uninitialized"
  ];

  buildInputs = [ openssl ];

  # it should work with qmake instead of autotools but while it compiles, it
  # doesn't install anything
  nativeBuildInputs = [ autoreconfHook libtool pkg-config qttools ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "An x509 certificate generation tool, handling RSA/DSA/EC keys, certificate signing requests (PKCS#10) and CRLs";
    homepage = "https://hohnstaedt.de/xca/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ offline peterhoeg ];
    platforms = platforms.all;
  };
}
