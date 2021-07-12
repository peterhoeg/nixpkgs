{ mkDerivation
, lib
, fetchFromGitHub
, cmake
}:

mkDerivation rec {
  pname = "kdsoap";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "KDAB";
    repo = "KDSoap";
    rev = "kdsoap-${version}";
    sha256 = "sha256-Cmfcp8lZ47aCoTojyRwMdp4+jvPYk5l8h0VAsRUOOtE=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ cmake ];

  postInstall = ''
    moveToOutput bin/kdwsdl2cpp "$dev"

    sed -i "$out/lib/cmake/KDSoap/KDSoapTargets.cmake" \
        -e "/^  INTERFACE_INCLUDE_DIRECTORIES/ c   INTERFACE_INCLUDE_DIRECTORIES \"$dev/include\""
    sed -i "$out/lib/cmake/KDSoap/KDSoapTargets-release.cmake" \
        -e "s@$out/bin@$dev/bin@"
  '';

  meta = with lib; {
    description = "A Qt-based client-side and server-side SOAP component";
    longDescription = ''
      KD Soap is a Qt-based client-side and server-side SOAP component.

      It can be used to create client applications for web services and also
      provides the means to create web services without the need for any further
      component such as a dedicated web server.
    '';
    license = with lib.licenses; [ gpl2 gpl3 lgpl21 ];
    maintainers = with maintainers; [ ttuegel ];
  };
}
