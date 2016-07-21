{ stdenv, fetchFromGitHub, cmake, qt5 }:

stdenv.mkDerivation rec {
  version = "0.3.0";
  name = "tensor-${version}";

  src = fetchFromGitHub {
    owner = "davidar";
    repo = "tensor";
    rev = "d87eee88bb398c32ba9793d9c5372b95e0464a4a";
    sha256 = "03yrvzl01v1a4nw79baaif7pdgniha0grdwn5lyns5r8x7wrig9j";
  };

  buildInputs = [ cmake qt5.qtbase ];

  cmakeFlags = ''
    -DCMAKE_BUILD_TYPE=Release
  '';

  meta = with stdenv.lib; {
    description = "QML client for Matrix";
    homepage = http://www.matrix.org;
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ peterhoeg ];
  };
}
