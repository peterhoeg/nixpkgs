{ stdenv, fetchFromGitHub, doxygen, meson, ninja, pkgconfig, yacc
, xkeyboard_config, libxcb, libX11
, wayland, wayland-protocols }:

stdenv.mkDerivation rec {
  name = "libxkbcommon-${version}";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner  = "xkbcommon";
    repo   = "libxkbcommon";
    rev    = "xkbcommon-${version}";
    sha256 = "1lamz7g1z1vilg6y8ndksd0z502p2faih43fhzqzbg1n9jvy6wh0";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ doxygen meson ninja pkgconfig ];

  buildInputs = [ yacc xkeyboard_config libxcb wayland wayland-protocols ];

  enableParallelBuilding = true;

  mesonFlags = [
    "-Dxkb-config-root=${xkeyboard_config}/etc/X11/xkb"
    "-Dx-locale-root=${libX11.out}/share/X11/locale"
  ];

  preBuild = stdenv.lib.optionalString stdenv.isDarwin ''
    sed -i 's/,--version-script=.*$//' Makefile
  '';

  meta = with stdenv.lib; {
    description = "A library to handle keyboard descriptions";
    homepage    = https://xkbcommon.org;
    license     = licenses.mit;
    maintainers = with maintainers; [ garbas ttuegel ];
    platforms   = with platforms; unix;
  };
}
