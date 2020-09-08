{
  mkDerivation,
  extra-cmake-modules,
  kwayland, plasma-wayland-protocols, wayland, wayland-protocols
}:

mkDerivation {
  name = "kwayland-server";
  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [ kwayland plasma-wayland-protocols wayland wayland-protocols ];
  # Without this patch, building anything that depends on this will fail as it
  # references a non-existant path.
  postInstall = ''
    mkdir -p $out/include/KF5
    mv $out/include/KWaylandServer $out/include/KF5/
  '';
}
