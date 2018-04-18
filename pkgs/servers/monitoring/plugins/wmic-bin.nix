{ stdenv, lib, fetchFromGitHub, patchelf, popt }:

let
  libs = stdenv.lib.concatStringsSep " " (map (e: "--add-needed ${e}") [
    "${stdenv.lib.getLib popt}/lib/libpopt.so.0"
  ]);

in stdenv.mkDerivation rec {
  name = "wmic-bin-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner  = "R-Vision";
    repo   = "wmi-client";
    rev    = version;
    sha256 = "1s1ggmgcgyq4bx3nab218l5pvzipx95p93xgcajkl76wblwb2b3s";
  };

  nativeBuildInputs = [ patchelf ];

  dontBuild = true;
  dontFixup = true;
  doInstallCheck = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/wmic_ubuntu_x64 $out/bin/wmic
    install -Dm644 -t $out/share/doc/wmic LICENSE README.md

    patchelf --set-interpreter ${stdenv.cc.libc.out}/lib/ld-*so.? \
      ${libs} $out/bin/wmic

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/wmic --help >/dev/null

    runHook postInstallCheck
  '';

  meta = with stdenv.lib; {
    description = "WMI client for Linux (binary)";
    homepage    = https://www.openvas.org;
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
