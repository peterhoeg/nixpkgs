{ stdenv, fetchFromGitHub, cmake
, qtbase }:

stdenv.mkDerivation rec {
  name = "libqmatrixclient-${version}";
  version = "0.3";

  src = fetchFromGitHub {
    owner  = "QMatrixClient";
    repo   = "libqmatrixclient";
    rev    = "v${version}";
    sha256 = "0cwzjbnh3p38rm53mhx65vx9dypfrw247wmhbd0ysgsqz51rmkid";
  };

  buildInputs = [ qtbase ];

  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    description= "A Qt5 library to write cross-platfrom clients for Matrix";
    homepage = https://matrix.org/docs/projects/sdk/libqmatrixclient.html;
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
