{ stdenv, fetchurl, autoreconfHook, libtool, pkgconfig, pam }:

stdenv.mkDerivation rec {
  name = "pam_tmpdir-${version}";
  version = "0.09";

  src = fetchurl {
    url    = "http://http.debian.net/debian/pool/main/p/pam-tmpdir/pam-tmpdir_${version}.tar.gz";
    sha256 = "17z0vrvfwzwp574r7llxcli5mhxzmjck0gpl2cvkz54siq4vaxii";
  };

  buildInputs = [ pam ];
  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  enableParallelBuilding = true;

  prePatch = ''
    rm -rf m4
    cp -r ${libtool}/share/aclocal m4
    chmod 755 m4
    chmod 644 m4/*
    sed -i Makefile.am \
      -e '/chown root/d' \
      -e '/chmod u/d'
  '';

  # Probably a hack, but using DESTDIR and PREFIX makes everything work!
  # postInstall = ''
    # mkdir -p $out
    # cp -r $out/$out/* $out
    # rm -r $out/nix
    # '';

  meta = with stdenv.lib; {
    description = "PAM module to mount volumes for a user session";
    homepage    = http://pam-mount.sourceforge.net/;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
