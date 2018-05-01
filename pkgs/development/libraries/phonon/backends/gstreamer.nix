{ stdenv, lib, fetchurl, cmake, pkgconfig, extra-cmake-modules
, qtbase, qtx11extras
, gst_all_1, libunwind, orc, pcre, phonon }:

with lib;

let
  v = "4.9.0";
  pname = "phonon-backend-gstreamer";

in stdenv.mkDerivation rec {
  name = "${pname}-${v}";

  src = fetchurl {
    url = "mirror://kde/stable/phonon/${pname}/${v}/${pname}-${v}.tar.xz";
    sha256 = "1wc5p1rqglf0n1avp55s50k7fjdzdrhg0gind15k8796w7nfbhyf";
  };

  # Hardcode paths to useful plugins so the backend doesn't depend
  # on system paths being set.
  patches = [ ./gst-plugin-paths.patch ];

  NIX_CFLAGS_COMPILE =
    let gstPluginPaths =
          lib.makeSearchPathOutput "lib" "/lib/gstreamer-1.0"
          (with gst_all_1; [
            gstreamer
            gst-plugins-base
            gst-plugins-good
            gst-plugins-ugly
            gst-plugins-bad
            gst-libav
          ]);
    in [
      # This flag should be picked up through pkgconfig, but it isn't.
      "-I${gst_all_1.gstreamer.dev}/lib/gstreamer-1.0/include"

      ''-DGST_PLUGIN_PATH_1_0="${gstPluginPaths}"''
    ];

  buildInputs = with gst_all_1;
    [ gstreamer gst-plugins-base
      qtbase qtx11extras
      libunwind orc pcre phonon ];

  # cleanup: the build system creates (empty) $out/$out/share/icons (double prefix)
  # if DESTDIR is unset
  DESTDIR="/";

  nativeBuildInputs = [ cmake pkgconfig extra-cmake-modules ];

  # [ "-DCMAKE_BUILD_TYPE=${if debug then "Debug" else "Release"}" ]
  cmakeFlags = [ "-DPHONON_BUILD_PHONON4QT5=ON" ];

  meta = with stdenv.lib; {
    description = "GStreamer backend for Phonon";
    homepage = https://phonon.kde.org/;
    maintainers = with maintainers; [ ttuegel ];
    platforms = platforms.linux;
  };

}
