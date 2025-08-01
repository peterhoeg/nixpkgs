{
  lib,
  fetchFromGitHub,
  fetchpatch,
  stdenv,
  makeWrapper,
  gitUpdater,
  cdrtools,
  curl,
  gawk,
  mesa-demos,
  gnugrep,
  gnused,
  jq,
  pciutils,
  procps,
  python3,
  qemu,
  socat,
  spice-gtk,
  swtpm,
  usbutils,
  util-linux,
  unzip,
  xdg-user-dirs,
  xrandr,
  zsync,
  OVMF,
  OVMFFull,
  testers,
  installShellFiles,
}:
let
  runtimePaths = [
    cdrtools
    curl
    gawk
    gnugrep
    gnused
    jq
    pciutils
    procps
    python3
    (qemu.override { smbdSupport = true; })
    socat
    swtpm
    util-linux
    unzip
    xrandr
    zsync
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    mesa-demos
    usbutils
    xdg-user-dirs
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "quickemu";
  version = "4.9.7";

  src = fetchFromGitHub {
    owner = "quickemu-project";
    repo = "quickemu";
    rev = finalAttrs.version;
    hash = "sha256-sCoCcN6950pH33bRZsLoLc1oSs5Qfpj9Bbywn/uA6Bc=";
  };

  patches = [
    (fetchpatch {
      name = "correctly-handle-version-10.0.0-of-qemu.patch";
      url = "https://github.com/quickemu-project/quickemu/commit/f25205f4513c4fa72be6940081c62e613d1fddc6.patch";
      hash = "sha256-OAXGyhMVDwbUypEPj/eRnH0wZYaL9WLGjbyoobe20UY=";
    })
  ];

  postPatch = ''
    sed -i \
      -e '/OVMF_CODE_4M.secboot.fd/s|ovmfs=(|ovmfs=("${OVMFFull.firmware}","${OVMFFull.variables}" |' \
      -e '/OVMF_CODE_4M.fd/s|ovmfs=(|ovmfs=("${OVMF.firmware}","${OVMF.variables}" |' \
      -e '/cp "''${VARS_IN}" "''${VARS_OUT}"/a chmod +w "''${VARS_OUT}"' \
      -e 's/Icon=.*qemu.svg/Icon=qemu/' \
      -e 's,\[ -x "\$(command -v smbd)" \],true,' \
      quickemu
  '';

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    installManPage docs/quickget.1 docs/quickemu.1 docs/quickemu_conf.5
    install -Dm755 -t "$out/bin" chunkcheck quickemu quickget quickreport

    # spice-gtk needs to be put in suffix so that when virtualisation.spiceUSBRedirection
    # is enabled, the wrapped spice-client-glib-usb-acl-helper is used
    for f in chunkcheck quickget quickemu quickreport; do
      wrapProgram $out/bin/$f \
        --prefix PATH : "${lib.makeBinPath runtimePaths}" \
        --suffix PATH : "${lib.makeBinPath [ spice-gtk ]}"
    done

    runHook postInstall
  '';

  passthru = {
    tests = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Quickly create and run optimised Windows, macOS and Linux virtual machines";
    homepage = "https://github.com/quickemu-project/quickemu";
    changelog = "https://github.com/quickemu-project/quickemu/releases/tag/${finalAttrs.version}";
    mainProgram = "quickemu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      fedx-sudo
      flexiondotorg
    ];
  };
})
