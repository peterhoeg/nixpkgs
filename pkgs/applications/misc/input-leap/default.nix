{ lib
, stdenv
, fetchFromGitHub
, cmake

, withLibei ? true

, avahi
, curl
, libICE
, libSM
, libX11
, libXdmcp
, libXext
, libXinerama
, libXrandr
, libXtst
, libei
, libportal
, openssl
, pkg-config
, qtbase
, qttools
, wrapQtAppsHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "input-leap";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "input-leap";
    repo = "input-leap";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YkBHvwN573qqQWe/p0n4C2NlyNQHSZNz2jyMKGPITF4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config cmake qttools wrapQtAppsHook ];

  buildInputs = [
    curl
    qtbase
    avahi
    libX11
    libXext
    libXtst
    libXinerama
    libXrandr
    libXdmcp
    libICE
    libSM
  ] ++ lib.optionals withLibei [ libei libportal ];

  cmakeFlags = [
    (lib.cmakeBool "INPUTLEAP_BUILD_LIBEI" withLibei)
    (lib.cmakeBool "INPUTLEAP_BUILD_TESTS" finalAttrs.doCheck or false)
  ];

  env.LANG = "C.UTF-8";

  preFixup = ''
    qtWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ openssl ]}"
    )
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/io.github.input_leap.InputLeap.desktop \
      --replace-fail "Exec=input-leap" "Exec=$out/bin/input-leap"
  '';

  meta = {
    description = "Open-source KVM software";
    longDescription = ''
      Input Leap is software that mimics the functionality of a KVM switch, which historically
      would allow you to use a single keyboard and mouse to control multiple computers by
      physically turning a dial on the box to switch the machine you're controlling at any
      given moment. Input Leap does this in software, allowing you to tell it which machine
      to control by moving your mouse to the edge of the screen, or by using a keypress
      to switch focus to a different system.
    '';
    homepage = "https://github.com/input-leap/input-leap";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ kovirobi phryneas twey shymega ];
    platforms = lib.platforms.linux;
  };
})
