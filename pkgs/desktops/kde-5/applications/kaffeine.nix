{
  fetchFromGitHub,
  kdeDerivation, lib, kdeWrapper,
  ecm, kdoctools,
  kio, kparts, kxmlgui, qtscript, solid,
  kconfig, kcoreaddons, kdbusaddons,
  libdvdread, vlc, xscreensaver
}:

let
  name = "kaffeine";
  version = "2.0.5";

  unwrapped = kdeDerivation {
    name = name;

    src = fetchFromGitHub {
      owner = "KDE";
      repo = name;
      rev = version;
      sha256 = "071r0gn1sivfr4mkvknr8ph52a9c0dhhs39ij4wqmfk0kwnczbd0";
    };

    nativeBuildInputs = [ ecm kdoctools ];
    propagatedBuildInputs = [
      kio kxmlgui solid
      libdvdread vlc xscreensaver
    ];

    meta = {
      license = with lib.licenses; [ gpl2 ];
      maintainers = with lib.maintainers; [ peterhoeg ];
    };
  };

in
  kdeWrapper unwrapped { targets = [ "bin/kaffeine" ]; }
