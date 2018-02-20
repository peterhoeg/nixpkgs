{ lib, stdenv, fetchFromGitHub, python3Packages, libinput, wmctrl, makeWrapper }:

python3Packages.buildPythonApplication rec {
  name = "libinput-gestures-${version}";
  version = "2.32";

  format = "other";

  src = fetchFromGitHub {
    owner = "bulletmark";
    repo = "libinput-gestures";
    rev = version;
    sha256 = "1by6sabx0s8sd9w5675gc26q7yccxnxxsjg4dqlb6nbs0vcg81s7";
  };

  patches = [
    ./0001-hardcode-name.patch
    ./0002-paths.patch
  ];

  postPatch = ''
    substituteInPlace libinput-gestures-setup \
      --replace /usr/ /

    substituteInPlace libinput-gestures \
      --replace      /etc     $out/etc \
      --subst-var-by libinput ${libinput}/bin/libinput \
      --subst-var-by wmctrl   ${wmctrl}/bin/wmctrl
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    ${stdenv.shell} libinput-gestures-setup -d $out install

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/libinput-gestures.desktop \
      --replace /usr/ $out/
    chmod +x $out/share/applications/libinput-gestures.desktop
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/bulletmark/libinput-gestures;
    description = "Gesture mapper for libinput";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
