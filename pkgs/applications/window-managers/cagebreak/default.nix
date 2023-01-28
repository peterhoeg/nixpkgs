{ lib
, stdenv
, fetchFromGitHub
, cairo
, fontconfig
, libevdev
, libinput
, libxkbcommon
, makeWrapper
, mesa
, meson
, ninja
, nixosTests
, pango
, pixman
, pkg-config
, scdoc
, systemd
, wayland
, wayland-protocols
, xorg
, withXwayland ? true
, xwayland
, wlroots
}:

stdenv.mkDerivation rec {
  pname = "cagebreak";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "project-repo";
    repo = pname;
    rev = version;
    hash = "sha256-qZP8shcdgfsA6PC1yHrMoEITOi14oIXpAXSYe2ivrjs=";
  };

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    scdoc
    wayland
  ];

  buildInputs = [
    cairo
    fontconfig
    libevdev
    libinput
    libxkbcommon
    mesa # for libEGL headers
    pango
    pixman
    systemd
    wayland
    wayland-protocols
    wlroots
    xorg.xcbutilwm
  ];

  mesonFlags = [
    "-Dman-pages=true"
    "-Dversion_override=${version}"
    "-Dxwayland=${lib.boolToString withXwayland}"
  ];

  postPatch = ''
    # TODO: investigate why is this happening
    sed -i -e 's|<drm_fourcc.h>|<libdrm/drm_fourcc.h>|' *.c

    # Patch cagebreak to read its default configuration from $out/share/cagebreak
    sed -i "s|/etc/xdg/cagebreak|$out/share/cagebreak|" meson.build cagebreak.c
  '';

  postFixup = lib.optionalString withXwayland ''
    wrapProgram $out/bin/cagebreak \
      --prefix PATH : "${lib.makeBinPath [ xwayland ]}"
  '';

  meta = with lib; {
    homepage = "https://github.com/project-repo/cagebreak";
    description = "A Wayland tiling compositor inspired by ratpoison";
    license = licenses.mit;
    maintainers = with maintainers; [ berbiche ];
    platforms = platforms.linux;
    changelog = "https://github.com/project-repo/cagebreak/blob/${version}/Changelog.md";
  };

  passthru.tests.basic = nixosTests.cagebreak;
}
