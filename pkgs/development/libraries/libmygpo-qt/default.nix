{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, qtbase, qjson }:

stdenv.mkDerivation rec {
  name = "libmygpo-qt-${version}";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner  = "gpodder";
    repo   = "libmygpo-qt";
    rev    = "${version}";
    sha256 = "117y51dpkfb5injgbjiry8cw6acmmjpp67mnbi1gimj2rynvwzma";
  };

  patches = [
    # should be able to drop this with the release following 1.1.0
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/gpodder/libmygpo-qt/pull/15.patch";
      name = "fix_qt5_11_build.patch";
      sha256 = "02pzhxg8j0bh3jw04qy214sfi49c8l1lbcvpynq0r8l599fdf1p3";
    })
  ];

  buildInputs = [ qtbase qjson ];

  nativeBuildInputs = [ cmake pkgconfig ];

  meta = with stdenv.lib; {
    description = "C++/Qt Client Library for gpodder.net";
    homepage    = http://gpodder.net;
    license     = licenses.lgpl21;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
