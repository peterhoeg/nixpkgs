{ stdenv, fetchurl, makeWrapper, premake4
, openal, libpng, libvorbis, mesa_glu, SDL2, SDL2_image, SDL2_ttf }:

stdenv.mkDerivation rec {
  name = "tome4-${version}";
  version = "1.5.5";

  src = fetchurl {
    url = "https://te4.org/dl/t-engine/t-engine4-src-${version}.tar.bz2";
    sha256 = "0v2qgdfpvdzd1bcbp9v8pfahj1bgczsq2d4xfhh5wg11jgjcwz03";
  };

  nativeBuildInputs = [ premake4 makeWrapper ];

  buildInputs = [
    mesa_glu openal libpng libvorbis SDL2 SDL2_ttf SDL2_image
  ];

  enableParallelBuilding = true;

  NIX_CFLAGS_COMPILE = [
    "-I${SDL2_image}/include/SDL2"
    "-I${SDL2_ttf}/include/SDL2"
  ];

  preConfigure = ''
    substituteInPlace premake4.lua \
      --replace "/opt/SDL-2.0/include/SDL2" "${SDL2.dev}/include/SDL2" \
      --replace "/usr/include/GL" "/run/opengl-driver/include"
    premake4 gmake
  '';

  makeFlags = [ "config=release" ];

  installPhase = ''
    runHook preInstall

    dir=$out/opt/tome4
    install -Dm755 t-engine $dir/t-engine
    cp -r bootstrap game $dir
    makeWrapper $dir/t-engine $out/bin/tome4

    runHook postInstall
  '';
  meta = with stdenv.lib; {
    description = "Tales of Maj'eyal (rogue-like game)";
    homepage = https://te4.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [ chattered ];
    platforms = platforms.linux;
  };
}
