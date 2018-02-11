{ stdenv, fetchurl, cmake, wxGTK30, openal, pkgconfig, curl, libtorrentRasterbar
, libpng, libX11, gettext, bash, gawk, boost, libnotify, gtk2, doxygen, spring
, makeWrapper, glib, minizip, alure, pcre, jsoncpp }:

stdenv.mkDerivation rec {
  name = "springlobby-${version}";
  version = "0.263";

  src = fetchurl {
    url = "http://www.springlobby.info/tarballs/springlobby-${version}.tar.bz2";
    sha256 = "07pi02wx0b8nvb4yz1l8cmbjzwyi01fd6jmc84am928ragdca95d";
  };

  nativeBuildInputs = [ cmake doxygen makeWrapper pkgconfig ];

  buildInputs = [
    wxGTK30 openal curl gettext libtorrentRasterbar pcre jsoncpp
    boost libpng libX11 libnotify gtk2 glib minizip alure
  ];

  enableParallelBuilding = true;

  postInstall = ''
    wrapProgram $out/bin/springlobby \
      --prefix PATH : "${spring}/bin" \
      --set SPRING_BUNDLE_DIR "${spring}/lib"
  '';

  meta = with stdenv.lib; {
    homepage = http://springlobby.info/;
    repositories.git = git://github.com/springlobby/springlobby.git;
    description = "Cross-platform lobby client for the Spring RTS project";
    license = licenses.gpl2;
    maintainers = with maintainers; [ phreedom qknight domenkozar ];
    platforms = platforms.linux;
  };
}
