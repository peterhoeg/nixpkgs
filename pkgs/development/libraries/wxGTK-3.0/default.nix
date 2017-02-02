{ stdenv, fetchurl, pkgconfig, libXinerama, libSM, libXxf86vm, xf86vidmodeproto
, gstreamer, gst_plugins_base, libnotify, setfile
, withGtk3 ? false, gtk2 ? null, gtk3 ? null
, withMesa ? true, mesa ? null, compat24 ? false, compat26 ? true, unicode ? true
, withWebKit ? false, webkitgtk2 ? null
, AGL ? null, Carbon ? null, Cocoa ? null, Kernel ? null, QTKit ? null
}:


assert withMesa -> mesa != null;
assert withWebKit -> webkitgtk2 != null;

with stdenv.lib;

let
  version = "3.0.2";
  gtk = (if withGtk3 then gtk3 else gtk2);

in stdenv.mkDerivation {
  name = "wxwidgets-${version}-gtk${if withGtk3 then "3" else "2"}";

  src = fetchurl {
    url = "mirror://sourceforge/wxwindows/wxWidgets-${version}.tar.bz2";
    sha256 = "0paq27brw4lv8kspxh9iklpa415mxi8zc117vbbbhfjgapf7js1l";
  };

  buildInputs =
    [ libnotify libXinerama libSM libXxf86vm xf86vidmodeproto
      gstreamer gst_plugins_base ]
    ++ [ gtk ]
    ++ optional withMesa mesa
    ++ optional (withWebKit && !withGtk3) webkitgtk2
    ++ optionals stdenv.isDarwin [ setfile Carbon Cocoa Kernel QTKit ];

  nativeBuildInputs = [ pkgconfig ];

  propagatedBuildInputs = optional stdenv.isDarwin AGL;

  configureFlags =
    [ "--disable-precomp-headers" "--enable-mediactrl"
      (if withGtk3 then "--enable-gtk3" else "--enable-gtk2")
      (if compat24 then "--enable-compat24" else "--disable-compat24")
      (if compat26 then "--enable-compat26" else "--disable-compat26") ]
    ++ optional unicode "--enable-unicode"
    ++ optional withMesa "--with-opengl"
    ++ optionals stdenv.isDarwin
      # allow building on 64-bit
      [ "--with-cocoa" "--enable-universal-binaries" "--with-macosx-version-min=10.7" ]
    ++ optionals withWebKit
      ["--enable-webview" "--enable-webview-webkit"];

  SEARCH_LIB = optionalString withMesa "${mesa}/lib";

  preConfigure = "
    substituteInPlace configure --replace 'SEARCH_INCLUDE=' 'DUMMY_SEARCH_INCLUDE='
    substituteInPlace configure --replace 'SEARCH_LIB=' 'DUMMY_SEARCH_LIB='
    substituteInPlace configure --replace /usr /no-such-path
  " + optionalString stdenv.isDarwin ''
    substituteInPlace configure --replace \
      'ac_cv_prog_SETFILE="/Developer/Tools/SetFile"' \
      'ac_cv_prog_SETFILE="${setfile}/bin/SetFile"'
    substituteInPlace configure --replace \
      "-framework System" \
      -lSystem
  '';

  postInstall = "
    (cd $out/include && ln -s wx-*/* .)
  ";

  passthru = {
    inherit compat24 compat26 gtk unicode;
  };

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    platforms = with platforms; darwin ++ linux;
  };
}
