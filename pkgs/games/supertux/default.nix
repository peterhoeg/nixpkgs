{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig, SDL2, SDL2_image, curl
, libogg, libvorbis, mesa, openal, boost, glew, physfs
}:

stdenv.mkDerivation rec {
  name = "supertux-${version}";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner  = "SuperTux";
    repo   = "supertux";
    rev    = "v${version}";
    sha256 = "1f1sqp7miq4lpk6dcxmmqkrhf26h90wcrc491jiwpifk0sjnla7h";
  };

  patches = [
    (fetchpatch {
      url = "https://trac.macports.org/raw-attachment/ticket/55172/physfs-livecheck.diff";
      sha256 = "1h0cc9c2hd341a2gnfwawcc13pxwpgcn94b091vzmcn6ajajkmw0";
    })
  ];

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ SDL2 SDL2_image boost curl libogg libvorbis mesa openal physfs glew ];

  enableParallelBuilding = true;

  cmakeFlags = [ "-DENABLE_BOOST_STATIC_LIBS=OFF" ];

  postInstall = ''
    mkdir $out/bin
    ln -s $out/games/supertux2 $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Classic 2D jump'n run sidescroller game";
    homepage = http://supertux.github.io/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ pSub ];
    platforms = with platforms; linux;
  };
}
