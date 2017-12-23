{ stdenv, fetchurl, alsaLib, libjack2, ncurses, pkgconfig }:

let
  instruments = fetchurl {
    url = http://www.csee.umbc.edu/pub/midia/instruments.tar.gz;
    sha256 = "0lsh9l8l5h46z0y8ybsjd4pf6c22n33jsjvapfv3rjlfnasnqw67";
  };

in stdenv.mkDerivation rec {
  name = "timidity-${version}";
  version = "2.14.0";

  src = fetchurl {
    url = "mirror://sourceforge/timidity/TiMidity++-${version}.tar.xz";
    sha256 = "1z46ii9q91qmwify9x8f1qwbs9zwhd8vv3svcfg5rs2rg4vciw5b";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ alsaLib libjack2 ncurses ];

  enableParallelBuilding = true;

  configureFlags = [
    "--enable-audio=oss,alsa,jack"
    "--enable-alsaseq"
    "--enable-dynamic=alsaseq,ncurses"
    "--enable-network"
    "--with-default-output=alsa"
    "--without-x"
  ];

  NIX_LDFLAGS = [ "-ljack -L${libjack2}/lib" ];

  # the instruments could be compressed (?)
  postInstall = ''
    mkdir -p $out/share/timidity/
    cp ${./timidity.cfg} $out/share/timidity/timidity.cfg
    tar --strip-components=1 -xf ${instruments} -C $out/share/timidity/
  '';

  meta = with stdenv.lib; {
    description = "A software MIDI renderer";
    homepage = https://sourceforge.net/projects/timidity/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ marcweber ];
    platforms = platforms.linux;
  };
}
