{ lib
, stdenv
, dotnetCorePackages
, dotnet-runtime_8
, buildDotnetModule
, fetchFromGitHub
, fontconfig
, xorg
, libglvnd
, makeDesktopItem
, copyDesktopItems
}:

let
  runtimes = [ "*musl*" "win*" ]
    ++ lib.optionals stdenv.isDarwin [ "linux*" ]
    ++ lib.optionals stdenv.isLinux [ "osx" ]
    ++ lib.optionals stdenv.targetPlatform.isAarch [ "*x64" ]
    ++ lib.optionals stdenv.targetPlatform.isx86 [ "*arm" "*arm64" ]
  ;

in
buildDotnetModule rec {
  pname = "mqttmultimeter";
  version = "1.8.2.272";

  src = fetchFromGitHub {
    owner = "chkr1011";
    repo = "mqttMultimeter";
    rev = "v" + version;
    hash = "sha256-vL9lmIhNLwuk1tmXLKV75xAhktpdNOb0Q4ZdvLur5hw=";
  };

  sourceRoot = "${src.name}/Source";

  projectFile = [ "mqttMultimeter.sln" ];
  nugetDeps = ./deps.nix;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnet-runtime_8;
  executables = [ "mqttMultimeter" ];

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [ stdenv.cc.cc.lib fontconfig ];

  postInstall = ''
    rm -rf $out/lib/mqttmultimeter/runtimes/{${lib.concatStringsSep "," runtimes}}

    for size in 16 24 32 48 64 128 256; do
      for f in icon_$size icon_det_$size; do
        file="../Images/Icons/$f.png"
        if [ -e "$file" ]; then
          install -Dm444 "$file" "$out/share/icons/hicolor/''${size}x''${size}/apps/${meta.mainProgram}.png"
        fi
      done
    done
  '';

  runtimeDeps = [
    libglvnd
    xorg.libSM
    xorg.libICE
    xorg.libX11
  ];

  desktopItems = makeDesktopItem {
    name = meta.mainProgram;
    exec = meta.mainProgram;
    icon = meta.mainProgram;
    desktopName = meta.mainProgram;
    genericName = meta.description;
    comment = meta.description;
    type = "Application";
    categories = [ "Network" ];
    startupNotify = true;
  };

  meta = with lib; {
    mainProgram = builtins.head executables;
    description = "MQTT traffic monitor";
    license = licenses.free;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
