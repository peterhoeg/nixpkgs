{ stdenv
, clangStdenv
, cmake
, gtest
, dotnetCorePackages
, buildDotnetModule
, writeShellScriptBin
, lib
, autoPatchelfHook
, fetchFromGitHub
, fetchzip
, git
, libunwind
, libuuid
, icu
, curl
, darwin
, makeWrapper
, less
, openssl_1_1
, pam
, lttng-ust
, zlib
}:

let
  version = "7.2.1";

  stdenv' = stdenv;
  # stdenv' = clangStdenv;

  sdk = dotnetCorePackages.sdk_6_0;
  runtime = dotnetCorePackages.runtime_6_0;

  git' = writeShellScriptBin "git" ''
    echo v${version}
  '';

  native = stdenv'.mkDerivation rec {
    pname = "powershell-native";
    version = "7.2.0";

    src = fetchFromGitHub {
      owner = "PowerShell";
      repo = "PowerShell-native";
      rev = "v${version}";
      sha256 = "sha256-BSpZ+yIlyMFdobFBM7miXLiRWFj6miCcXUHfXcpOK9I=";
      fetchSubmodules = true;
    };

    sourceRoot = "source/src/libpsl-native";

    enableParallelBuilding = false;

    buildInputs = [ zlib ];

    nativeBuildInputs = [ cmake gtest ];

    # cmakeFlags = [
    #   "-DBUILD_TARGET_ARCH=x64"
    # ];
  };

in
buildDotnetModule rec {
  pname = "powershell";
  inherit version;

  src = fetchFromGitHub {
    owner = "PowerShell";
    repo = "PowerShell";
    rev = "v${version}";
    sha256 = "sha256-8I+viIJA8NgCNf9j79OogoEX3vNMBGNRXyNi8orHqiU=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  postPatch = ''
    echo "v${version}" > powershell.version
    # substituteInPlace tools/releaseTools.psm1 \
      # --replace 'NuGetVersion = $newVersionString' 'NuGetVersion = "${version}"'
  '';

  buildInputs = [
    native

    less
    libunwind
    libuuid
    icu
    curl
    openssl_1_1
  ]
  ++ lib.optionals stdenv'.isLinux [ pam lttng-ust ]
  ++ lib.optionals stdenv'.isDarwin [ darwin.Libsystem ];

  nativeBuildInputs = [ git' makeWrapper ];

  dotnet-sdk = sdk;

  dotnet-runtime = runtime;

  projectFile = "PowerShell.sln";
  nugetDeps = ./deps.nix;

  preBuild = ''
    set -x
  '';

  makeWrapperArgs = [
    "--set TERM xterm"
    "--set POWERSHELL_TELEMETRY_OPTOUT 1 --set DOTNET_CLI_TELEMETRY_OPTOUT 1"
  ];

  doInstallCheck = true;
  # May need a writable home, seen on Darwin.
  installCheckPhase = ''
    HOME=$TMP $out/bin/pwsh --help > /dev/null
  '';

  meta = with lib; {
    description = "Powerful cross-platform (Windows, Linux, and macOS) shell and scripting language based on .NET";
    homepage = "https://github.com/PowerShell/PowerShell";
    maintainers = with maintainers; [ yrashk srgom p3psi ];
    platforms = [ "x86_64-darwin" "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    license = with licenses; [ mit ];
    mainProgram = "bin/pwsh";
  };

  passthru = {
    shellPath = "/bin/pwsh";
  };
}
