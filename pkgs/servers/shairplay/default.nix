{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, writeText
, avahi, libao }:

let
  description = "Apple AirPlay and RAOP protocol server";

  unit = writeText "shairplay.service" ''
    [Unit]
    Description=${description}
    Requires=network.target sound.target
    Wants=avahi-daemon.service
    After=avahi-daemon.service

    [Service]
    Type=simple
    ExecStart=@out@/bin/shairplay -a %H
    Restart=always

    [Install]
    WantedBy=multi-user.target
  '';

in stdenv.mkDerivation rec {
  name = "shairplay-${version}";
  version = "2016-01-01";

  src = fetchFromGitHub {
    owner  = "juhovh";
    repo   = "shairplay";
    rev    = "ce80e005908f41d0e6fde1c4a21e9cb8ee54007b";
    sha256 = "10b4bmqgf4rf1wszvj066mc42p90968vqrmyqyrdal4k6f8by1r6";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ avahi libao ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace src/shairplay.c \
      --replace '"airport.key"' '"$out/share/shairplay/airport.key"'
  '';

  postInstall = ''
    install -Dm644 -t $out/share/shairplay airport.key

    mkdir -p $out/lib/systemd/system
    substitute ${unit} $out/lib/systemd/system/shairplay.service \
      --subst-var out
  '';

  # the build will fail complaining about a reference to /tmp
  preFixup = ''
    patchelf \
      --set-rpath "${stdenv.lib.makeLibraryPath buildInputs}:$out/lib" \
      $out/bin/shairplay
  '';

  meta = with stdenv.lib; {
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
    inherit description;
    inherit (src.meta) homepage;
  };
}
