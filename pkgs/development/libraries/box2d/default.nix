{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "box2d-${version}";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "erincatto";
    repo = "Box2D";
    rev = "v${version}";
    sha256 = "12rw4nwv5mp0nfrjjyzgymcw2ghdi7nfa6hj01mdch1khgnpaqk7";
  };

  sourceRoot = "source/Box2D";

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    # Technically not needed yet but will be when it moves to premake
    substituteInPlace premake4.lua \
      --replace StaticLib SharedLib

    # 2.3.1 is still tagged as 2.3.0
    substituteInPlace CMakeLists.txt \
      --replace 2.3.0 ${version}

    substituteInPlace Box2D/Common/b2Settings.h \
      --replace 'b2_maxPolygonVertices	8' 'b2_maxPolygonVertices	15'
  '';

  cmakeFlags = [
    "-DBOX2D_BUILD_EXAMPLES=OFF"
    "-DBOX2D_BUILD_SHARED=ON"
    "-DBOX2D_BUILD_STATIC=OFF"
    "-DBOX2D_INSTALL=ON"
  ];

  meta = with stdenv.lib; {
    description = "2D physics engine";
    homepage = http://box2d.org/;
    maintainers = with maintainers; [ raskin ];
    license = licenses.zlib;
    platforms = platforms.linux;
  };
}
