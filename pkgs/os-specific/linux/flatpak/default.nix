{ stdenv, fetchFromGitHub, autoreconfHook, dbus, systemd }:

let
  version = "0.6.10";

  libglnx-src = fetchFromGitHub {
    owner  = "GNOME";
    repo   = "libglnx";
    rev    = "769522753c25537e520adc322fa62e5390272add";
    sha256 = "0gfc8dl63xpmf73dwb1plj7cymq7z6w6wq5m06yx8jymwhq7x1l8";
  };

  bubblewrap-src = fetchFromGitHub {
    owner  = "projectatomic";
    repo   = "bubblewrap";
    rev    = "master";
    sha256 = "006myx7bqafglwh1s5121bb90kr2cnsfnqzlr6b9x83ddda1wf6g";
  };

in stdenv.mkDerivation {
  name = "flatpak-${version}";

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = "flatpak";
    rev = version;
    sha256 = "07167cwwm7bfl6k70czwg3l0kv33bwpbbc0szv4fdlyv8jcl4kfg";
  };

  buildInputs = [ autoreconfHook bubblewrap-src libglnx-src dbus systemd ];

  prePatch = ''
    rmdir bubblewrap libglnx
    cp --no-preserve=mode -r ${libglnx-src} libglnx
    cp --no-preserve=mode -r ${bubblewrap-src} bubblewrap
  '';

  preConfigure = ''
    env NOCONFIGURE=1 ./autogen.sh
  '';

  meta = with stdenv.lib; {
    homepage = http://www.flatpak.org;
    description = "Run applications in sandboxes";
    platforms = platforms.linux;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
