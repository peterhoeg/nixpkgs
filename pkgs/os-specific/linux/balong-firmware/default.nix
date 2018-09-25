{ stdenv, fetchFromGitHub, zlib }:

let
  owner = "forth32";

  balong-usbdload = stdenv.mkDerivation rec {
    name = "balong-usbdload-${version}";
    version = "20180211";

    src = fetchFromGitHub {
      inherit owner;
      repo   = "balong-usbdload";
      rev    = "752a2de73b944ee16d5eb0f263928cf72b0f6851";
      sha256 = "1i20k98s9khh88bi6025a2kf778p6awz413njphaq52my38biabp";
    };

    enableParallelBuilding = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 -t $out/bin balong-usbdload loader-patch ptable-injector ptable-list

      runHook postInstall
    '';
  };

  balongflash = stdenv.mkDerivation rec {
    name = "balongflash-${version}";
    version = "20180611";

    src = fetchFromGitHub {
      inherit owner;
      repo   = "balongflash";
      rev    = "de76d92154a7035904b523e730366ac4890ff64a";
      sha256 = "16yj7sabmzqxzixyhclxpwpm8d3zqzs504kvdnspm8x3lhx8516h";
    };

    buildInputs = [ zlib ];

    enableParallelBuilding = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 -t $out/bin balong_flash

      runHook postInstall
    '';
  };

in {
  inherit balong-usbdload balongflash;
}
