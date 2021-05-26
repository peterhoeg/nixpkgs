{ mkDerivation, fetchurl, lib
, extra-cmake-modules
}:

mkDerivation rec {
  pname = "plasma-wayland-protocols";
  version = "1.3.0";

  src = fetchurl {
    urls = [
      "mirror://kde/stable/${pname}/${pname}-${version}.tar.xz"
      # v1.2.1 has a v version prefix
      "mirror://kde/stable/${pname}/${pname}-v${version}.tar.xz"
    ];
    sha256 = "sha256-DaojYvLg0V954OAG6NfxkI6I43tcUgi0DJyw1NbcqbU=";
  };

  nativeBuildInputs = [ extra-cmake-modules ];

  meta = {
    description = "Plasma Wayland Protocols";
    license = lib.licenses.lgpl21Plus;
    platforms = qtbase.meta.platforms;
    maintainers = [ lib.maintainers.ttuegel ];
  };
}
