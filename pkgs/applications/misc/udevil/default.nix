{ stdenv, lib, fetchFromGitHub, autoreconfHook, intltool, glib, pkg-config, systemd, util-linux, acl }:

stdenv.mkDerivation rec {
  pname = "udevil";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "IgnorantGuru";
    repo = "udevil";
    rev = version;
    sha256 = "sha256-TTW2gPa4ND6ILq4yxKEL07AQpSqfiEo66S72lVEmpFk=";
  };

  patches = [ ./device-info-sys-stat.patch ];

  nativeBuildInputs = [ pkg-config ]; # autoreconfHook

  buildInputs = [ intltool glib systemd ];

  # our Makefile.in patch doesn't work if we use autoreconfHook

  postPatch = ''
    substituteInPlace etc/systemd/devmon@.service \
      --replace /etc/conf.d/devmon /etc/udevil/devmon \
      --replace /usr/bin $out/bin

    substituteInPlace src/Makefile.in \
      --replace "-o root -g root" "" \
      --replace 4755 0755
  '';

  configureFlags = [
    "--with-mount-prog=${util-linux}/bin/mount"
    "--with-umount-prog=${util-linux}/bin/umount"
    "--with-losetup-prog=${util-linux}/bin/losetup"
    "--with-setfacl-prog=${acl.bin}/bin/setfacl"
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  meta = with lib; {
    description = "A command line Linux program which mounts and unmounts removable devices without a password, shows device info, and monitors device changes";
    homepage = "https://ignorantguru.github.io/udevil/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
