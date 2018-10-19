{ stdenv, fetchFromGitLab
, pkgconfig
, qmake, qtbase, qtquickcontrols2, qtmultimedia
, libpulseaudio, libqmatrixclient
# Not mentioned but seems needed
, qtgraphicaleffects
# Unsure but needed by similar
, qtdeclarative, qtsvg
}:

let
  sort-filter-proxy-model = fetchFromGitLab {
    owner  = "b0";
    repo   = "SortFilterProxyModel";
    rev    = "c61f2bdb0da48804a596a9a3a9382eebdba764dc";
    sha256 = "102dciv082nhaav9x06q7i3dani3rpaa0llciav92j178v6ldkkb";
  };

in stdenv.mkDerivation rec {
  name = "spectral-${version}";
  version = "2018-10-18";

  src = fetchFromGitLab {
    owner  = "b0";
    repo   = "spectral";
    rev    = "d35405696ffeb92e370a5a9600c7a478f55cde78";
    sha256 = "0xm8gkxqk75c0xs69dgr0nc241zcb7d9hcrwvvhc4dh3543y0mpn";
  };

  # libqmatrixclient is still not ready so we are using the source
  postPatch = ''
    rm -rf include/{SortFilterProxyModel,libqmatrixclient}
    ln -sf ${sort-filter-proxy-model} include/SortFilterProxyModel
    ln -sf ${libqmatrixclient.src}    include/libqmatrixclient
  '';

  nativeBuildInputs = [ pkgconfig qmake ];
  buildInputs = [
    qtbase qtquickcontrols2 qtmultimedia qtgraphicaleffects qtdeclarative qtsvg
  ] ++ stdenv.lib.optional stdenv.hostPlatform.isLinux libpulseaudio;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A glossy client for Matrix, written in QtQuick Controls 2 and C++";
    homepage = https://gitlab.com/b0/spectral;
    license = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
    platforms = with platforms; linux ++ darwin;
  };
}
