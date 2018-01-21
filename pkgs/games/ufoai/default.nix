{ stdenv, fetchurl, libtheora, xvidcore, mesa, SDL, SDL_ttf, SDL_mixer
, curl, libjpeg, libpng, gettext, cunit
, openal, zip, python
, enableEditor ? false }:

let
  name = "ufoai-2.5";

  srcData = fetchurl {
    url = "mirror://sourceforge/ufoai/${name}-data.tar";
    sha256 = "1c6dglmm36qj522q1pzahxrqjkihsqlq2yac1aijwspz9916lw2y";
  };

in stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    url = "mirror://sourceforge/ufoai/${name}-source.tar.bz2";
    sha256 = "13ra337mjc56kw31m7z77lc8vybngkzyhvmy3kvpdcpyksyc6z0c";
  };

  preConfigure = ''
    tar xvf "${srcData}"
  '';

  configureFlags = [ "--enable-release" "--enable-sse" ]
    ++ stdenv.lib.optional enableEditor "--enable-uforadiant";

  buildInputs = [
    libtheora xvidcore mesa SDL SDL_ttf SDL_mixer
    curl libjpeg libpng
    openal
    zip python
  ];

  nativeBuildInputs = [ cunit gettext ];

  NIX_CFLAGS_LINK = "-lgcc_s"; # to avoid occasional runtime error in finding libgcc_s.so.1

  meta = with stdenv.lib; {
    homepage = http://ufoai.org;
    description = "A squad-based tactical strategy game in the tradition of X-Com";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [viric];
    platforms = platforms.linux;
  };
}
