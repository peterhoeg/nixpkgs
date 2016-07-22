{ stdenv, fetchFromGitHub, git, go, syncthing }:

stdenv.mkDerivation rec {
  version = "0.8.3";
  name = "syncthing-inotify-${version}";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "syncthing";
    repo = "syncthing-inotify";
    sha256 = "194pbz9zzxaz0vri93czpbsxl85znlba2gy61mjgyr0dm2h4s6yw";
  };

  # buildInputs = [ backoff notify ];
  buildInputs = [ git go ];

  buildPhase = ''
    mkdir -p src/github.com/syncthing
    ln -s $(pwd) src/github.com/syncthing/syncthing-inotify
    export GOPATH=$(pwd)

    # Syncthing's build.go script expects this working directory
    cd src/github.com/syncthing/syncthing-inotify

    go get
    go build -ldflags "-w -X main.Version `git describe --abbrev=0 --tags`"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin
  '';

  meta = {
    homepage = https://www.syncthing.net/;
    description = "Inotify based watch for Syncthing - the Open Source Continuous File Synchronization tool";
    license = stdenv.lib.licenses.mpl20;
    maintainers = with stdenv.lib.maintainers; [peterhoeg];
    platforms = with stdenv.lib.platforms; linux ++ freebsd ++ openbsd ++ netbsd;
  };
}
