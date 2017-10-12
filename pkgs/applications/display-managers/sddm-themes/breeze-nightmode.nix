{ stdenv, fetchurl  }:

let
  pname = "breeze-nightmode";

in stdenv.mkDerivation rec {
  name = "sddm-theme-${pname}-${version}";
  version = "0.584";

  src = fetchurl {
    url = "https://dl.opendesktop.org/api/files/download/id/1482519838/breeze-nightmode.tar.gz";
    sha256 = "1lgnpysvxvyidfsi4s7yn4xg2madz1zjsifg9vz7w1af0h8cb1hd";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    set -u

    dir=$out/share/sddm/themes/${pname}

    mkdir -p $dir $out/share/doc
    cp -r * $dir/
    mv $dir/Notes $out/share/doc/${pname}

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Breeze NightMode theme for SDDM";
    homepage = https://github.com/sddm/sddm;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.all;
  };
}
