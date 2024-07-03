{ stdenv
, lib
, fetchurl
, cmake
, pkg-config
, qtbase
, qttools
, qtx11extras ? null
, wrapQtAppsHook
, drumstick
, docbook-xsl-nons
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vmpk";
  version = "0.9.0";

  src = fetchurl {
    url = "mirror://sourceforge/vmpk/${finalAttrs.version}/vmpk-${finalAttrs.version}.tar.bz2";
    hash = "sha256-xH7hTL8ZAwdUQKytcp2ODgLkyYYGGDdWZ27qwaGuvNk=";
  };

  nativeBuildInputs = [ cmake pkg-config qttools docbook-xsl-nons wrapQtAppsHook ];

  buildInputs = [ drumstick qtbase qtx11extras ];

  env.LANG = "C.UTF-8";

  cmakeFlags = [
    (lib.cmakeBool "USE_QT5" ((lib.versions.major qtbase.version) == "5"))
  ];

  postInstall = ''
    # vmpk drumstickLocales looks here:
    ln -s ${drumstick}/share/drumstick $out/share/
  '';

  meta = with lib; {
    description = "Virtual MIDI Piano Keyboard";
    mainProgram = "vmpk";
    homepage = "https://vmpk.sourceforge.net/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ orivej ];
    platforms = platforms.linux;
  };
})
