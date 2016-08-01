{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "syncthing-inotify-${version}";
  version = "0.8.3";

  goPackagePath = "github.com/syncthing/syncthing-inotify";

  src = fetchFromGitHub {
    owner = "syncthing";
    repo = "syncthing-inotify";
    rev = "v${version}";
    sha256 = "194pbz9zzxaz0vri93czpbsxl85znlba2gy61mjgyr0dm2h4s6yw";
  };

  goDeps = ./inotify-deps.json;

  preInstall = ''
    mkdir -p $out/bin $out/lib/systemd/{system,user}
    cp $src/etc/linux-systemd/system/* $out/lib/systemd/system/
    cp $src/etc/linux-systemd/user/*   $out/lib/systemd/user/
  '';

  meta = {
    homepage = https://github.com/syncthing/syncthing-inotify;
    description = "File watcher intended for use with Syncthing";
    license = stdenv.lib.licenses.mpl20;
    maintainers = with stdenv.lib.maintainers; [ joko ];
    platforms = with stdenv.lib.platforms; linux ++ freebsd ++ openbsd ++ netbsd;
  };

}
