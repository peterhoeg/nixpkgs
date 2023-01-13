{ mkDerivation, lib, fetchFromGitHub, cmake, olm, openssl, qtmultimedia, qtkeychain }:

mkDerivation rec {
  pname = "libquotient";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "quotient-im";
    repo = "libQuotient";
    rev = version;
    sha256 = "sha256-9NAWphpAI7/qWDMjsx26s+hOaQh0hbzjePfESC7PtXc=";
  };

  # https://github.com/quotient-im/libQuotient/issues/551
  postPatch = ''
    substituteInPlace Quotient.pc.in \
      --replace '$'{prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
      --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  '';

  buildInputs = [ olm openssl qtmultimedia qtkeychain ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    # E2EE is not declared stable by upstream yet, but better get it out there to get some testing
    "-DQuotient_ENABLE_E2EE=ON"
  ];

  meta = with lib; {
    description = "A Qt5 library to write cross-platform clients for Matrix";
    homepage = "https://matrix.org/docs/projects/sdk/quotient";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ colemickens ];
  };
}
