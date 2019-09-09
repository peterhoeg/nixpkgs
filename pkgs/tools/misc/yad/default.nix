{ stdenv, fetchFromGitHub, pkgconfig, intltool, autoreconfHook, wrapGAppsHook
, gtk3, hicolor-icon-theme, netpbm }:

stdenv.mkDerivation rec {
  pname = "yad";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "v1cont";
    repo = "yad";
    rev = version;
    sha256 = "192j2q9fjifwq4v1whfsvcrl0lk1b7vzasa1sq9qjjr0i6y10mp9";
  };

  configureFlags = [
    "--enable-icon-browser"
    "--with-rgb=${placeholder "out"}/share/yad/rgb.txt"
  ];

  buildInputs = [ gtk3 hicolor-icon-theme ];

  nativeBuildInputs = [ autoreconfHook pkgconfig intltool wrapGAppsHook ];

  enableParallelBuilding = true;

  postPatch = ''
    sed -i src/file.c -e '21i#include <glib/gprintf.h>'
    sed -i src/form.c -e '21i#include <stdlib.h>'

    # there is no point to bring in the whole netpbm package just for this file
    install -Dm644 ${netpbm}/share/netpbm/misc/rgb.txt $out/share/yad/rgb.txt
  '';

  postAutoreconf = ''
    intltoolize
  '';

  meta = with stdenv.lib; {
    homepage = https://sourceforge.net/projects/yad-dialog/;
    description = "GUI dialog tool for shell scripts";
    longDescription = ''
      Yad (yet another dialog) is a GUI dialog tool for shell scripts. It is a
      fork of Zenity with many improvements, such as custom buttons, additional
      dialogs, pop-up menu in notification icon and more.
    '';

    license = licenses.gpl3;
    maintainers = with maintainers; [ smironov ];
    platforms = with platforms; linux;
  };
}
