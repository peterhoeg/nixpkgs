{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf-archive,
  autoreconfHook,
  chromium,
  pkg-config,
  python3,
  runCommand,
  zstd,
}:
let
  hsts_list =
    runCommand "transport_security_state_static.json"
      {
        nativeBuildInputs = [ zstd ];
      }
      ''
        tar -xvf ${chromium.passthru.browser.chromiumDeps.src} ./net/http/transport_security_state_static.json
        cp ./net/http/transport_security_state_static.json $out
        sed -i '/^ *\/\/.*$/d' $out
      '';
in
stdenv.mkDerivation rec {
  pname = "libhsts";
  version = "0.1.0";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitLab {
    owner = "rockdaboot";
    repo = "libhsts";
    tag = "libhsts-${version}";
    hash = "sha256-pM9ZFk8W73Sx3ru/mqN/rWYMyZnNFCa/Wb8TB9yHbD0=";
  };

  patches = [
    ./gettext-0.25.patch
  ];

  postPatch = ''
    cp ${hsts_list} tests/hsts.json
    patchShebangs src/hsts-make-dafsa
  '';

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
    python3
  ];

  meta = with lib; {
    description = "Library to easily check a domain against the Chromium HSTS Preload list";
    mainProgram = "hsts";
    homepage = "https://gitlab.com/rockdaboot/libhsts";
    license = with lib.licenses; [
      mit
      bsd3
    ];
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
