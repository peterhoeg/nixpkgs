{ stdenv, lib, fetchFromGitHub, cmake
, qtbase, qtquickcontrols, qttools, libqmatrixclient }:

stdenv.mkDerivation rec {
  name = "quaternion-${version}";
  version = "rc0.0.9.3";

  src = fetchFromGitHub {
    owner  = "QMatrixClient";
    repo   = "Quaternion";
    rev    = "${version}";
    sha256 = "1qn46ymfl5mm3izb498b511g2mjc51wgm9kjbmikjq2bhn2wlk4a";
  };

  buildInputs = [ qtbase qtquickcontrols libqmatrixclient ];

  nativeBuildInputs = [ cmake qttools ];

  postInstall = if stdenv.isDarwin then ''
    mkdir -p $out/Applications
    mv $out/bin/quaternion.app $out/Applications
    rmdir $out/bin || :
  '' else ''
    substituteInPlace $out/share/applications/quaternion.desktop \
      --replace 'Exec=quaternion' "Exec=$out/bin/quaternion"
  '';

  meta = with lib; {
    description = "Cross-platform desktop IM client for the Matrix protocol";
    homepage    = https://matrix.org/docs/projects/client/quaternion.html;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (qtbase.meta) platforms;
    inherit version;
  };
}
