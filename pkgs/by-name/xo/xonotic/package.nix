{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  autoreconfHook,
  pkg-config,
  makeWrapper,
  runCommandLocal,
  makeDesktopItem,
  copyDesktopItems,
  # required for both
  unzip,
  libjpeg,
  zlib,
  libvorbis,
  curl,
  freetype,
  libpng,
  libtheora,
  libX11,
  # glx
  libGLU,
  libGL,
  libXpm,
  libXext,
  libXxf86vm,
  alsa-lib,
  # sdl
  SDL2,
  # blind
  gmp,
  symlinkJoin,

  withSDL ? true,
  withGLX ? false,
  withDedicated ? true,
}:

let
  pname = "xonotic";
  version = "0.8.6";
  variant =
    if withSDL && withGLX then
      ""
    else if withSDL then
      "-sdl"
    else if withGLX then
      "-glx"
    else if withDedicated then
      "-dedicated"
    else
      "-what-even-am-i";

  meta = {
    description = "Free fast-paced first-person shooter";
    longDescription = ''
      Xonotic is a free, fast-paced first-person shooter that works on
      Windows, macOS and Linux. The project is geared towards providing
      addictive arena shooter gameplay which is all spawned and driven
      by the community itself. Xonotic is a direct successor of the
      Nexuiz project with years of development between them, and it
      aims to become the best possible open-source FPS of its kind.
    '';
    homepage = "https://www.xonotic.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      zalakain
    ];
    platforms = lib.platforms.linux;
    mainProgram = "xonotic-${variant}";
  };

  src = fetchurl {
    url = "https://dl.xonotic.org/xonotic-${version}-source.zip";
    hash = "sha256-i5KseBz/SuicEhoj6s197AWiqr7azMI6GdGglYtAEqg=";
  };

  d0-blind-id = stdenv.mkDerivation (finalAttrs: {
    pname = "d0-blind-id";
    inherit version src;
    sourceRoot = "Xonotic/source/d0_blind_id";
    nativeBuildInputs = [
      autoreconfHook
      pkg-config
      unzip
    ];
    buildInputs = [ gmp ];
    enableParallelBuilding = true;
  });

  xonotic-unwrapped = stdenv.mkDerivation rec {
    pname = "xonotic${variant}-unwrapped";
    inherit version src;

    nativeBuildInputs = [ unzip ];

    buildInputs = [
      curl
      d0-blind-id
      libX11
      libjpeg
      libvorbis
      zlib
    ]
    ++ lib.optionals withGLX [
      alsa-lib
      libGL
      libGLU
      libXext
      libXpm
      libXxf86vm
    ]
    ++ lib.optionals withSDL [ SDL2 ];

    sourceRoot = "Xonotic/source/darkplaces";

    # "debug", "release", "profile"
    target = "release";

    dontStrip = target != "release";

    makeFlags =
      lib.optionals withDedicated [ "sv-${target}" ]
      ++ lib.optionals withGLX [ "cl-${target}" ]
      ++ lib.optionals withSDL [ "sdl-${target}" ];

    enableParallelBuilding = true;

    installPhase = ''
      runHook preInstall

      install -Dm644 ../../misc/logos/xonotic_icon.svg \
        $out/share/icons/hicolor/scalable/apps/xonotic.svg
      pushd ../../misc/logos/icons_png
      for img in *.png; do
        size=''${img#xonotic_}
        size=''${size%.png}
        dimensions="''${size}x''${size}"
        install -Dm644 $img \
          $out/share/icons/hicolor/$dimensions/apps/xonotic.png
      done
      popd

      for suffix in dedicated glx sdl; do
        file=darkplaces-$suffix
        test -x "$file" && install -Dm555 "$file" "$out/libexec/xonotic-$suffix"
      done

      runHook postInstall
    '';

    # Xonotic needs to find libcurl.so at runtime for map downloads
    postFixup = ''
      for f in $out/libexec/xonotic-* ; do
        patchelf "$f" \
          --add-needed ${lib.getLib curl}/lib/libcurl.so
      done
    '';
  };

  xonotic-data = fetchzip {
    name = "xonotic-data";
    url = "https://dl.xonotic.org/xonotic-${version}.zip";
    hash = "sha256-Lhjpyk7idmfQAVn4YUb7diGyyKZQBfwNXxk2zMOqiZQ=";
    postFetch = ''
      cd $out
      rm -rf $(ls | grep -v "^data$" | grep -v "^key_0.d0pk$")
    '';
  };

in
runCommandLocal "xonotic${variant}-${version}"
  {
    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
    ];
    desktopItems = lib.optionals (withGLX || withSDL) [
      (makeDesktopItem {
        name = "xonotic";
        exec = "xonotic";
        comment = meta.description;
        desktopName = "Xonotic";
        categories = [
          "Game"
          "Shooter"
        ];
        icon = "xonotic";
        startupNotify = false;
      })
    ];
    inherit meta;
  }
  ''
    for binary in ${xonotic-unwrapped}/libexec/xonotic-*; do
      makeWrapper "$binary" $out/bin/$(basename "$binary") \
        --add-flags "-basedir ${xonotic-data}" \
        --prefix LD_LIBRARY_PATH : "${xonotic-unwrapped}/lib"
    done

    if [ -n "${variant}" ]; then
      ln -s $out/bin/xonotic${variant} $out/bin/xonotic
    fi
  ''
