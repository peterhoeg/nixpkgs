{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
}:

let
  release = "0.1.0.2025-03-16";

in
stdenv.mkDerivation {
  pname = "acer-wmi-battery";
  version = "${kernel.version}-${release}";

  src = fetchFromGitHub {
    owner = "frederik-h";
    repo = "acer-wmi-battery";
    # rev = "v" + release;
    rev = "d8ee59fffce1710d21782535d1b1a91820eda4d7";
    hash = "sha256-sFTO3CcNyR2UGr2WFubhgSau9bcQVlxci0LG38FRqd8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '/lib/modules/$(shell uname -r)/build' ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
  '';

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    find . -name '*.ko' -exec xz -f {} \;
    install -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86 *.ko.xz

    runHook postInstall
  '';

  meta = with lib; {
    description = "Driver for the Acer WMI battery health control interface";
    homepage = "https://github.com/frederik-h/acer-wmi-battery";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
