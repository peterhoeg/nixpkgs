{ stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "libdnet-1.12";

  src = fetchFromGitHub {
    owner  = "dugsong";
    repo   = "libdnet";
    rev    = name;
    sha256 = "1g2x0g1irxlhg2m3nd5d1vycmp489a7nafnnyalsh1w90fzlfw05";
  };

  enableParallelBuilding = true;

  # .so endings are missing (quick and dirty fix)
  postInstall = ''
    for i in $out/lib/*; do
      ln -s $i $i.so
    done
  '';

  meta = with stdenv.lib; {
    description = "Provides a simplified, portable interface to several low-level networking routines";
    homepage    = https://github.com/dugsong/libdnet;
    license     = licenses.bsd3;
    maintainers = with maintainers; [ marcweber ];
    platforms   = platforms.linux;
  };
}
