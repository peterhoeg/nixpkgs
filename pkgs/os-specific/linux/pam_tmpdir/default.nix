{ stdenv, fetchurl, autoreconfHook, libtool, pam }:

stdenv.mkDerivation rec {
  name = "pam_tmpdir-${version}";
  version = "0.09";

  src = fetchurl {
    url    = "http://http.debian.net/debian/pool/main/p/pam-tmpdir/pam-tmpdir_${version}.tar.gz";
    sha256 = "17z0vrvfwzwp574r7llxcli5mhxzmjck0gpl2cvkz54siq4vaxii";
  };

  buildInputs = [ pam ];
  nativeBuildInputs = [ autoreconfHook ];
  enableParallelBuilding = true;

  prePatch = ''
    install -m644 ${libtool}/share/aclocal/*.m4 -t m4
    sed -i Makefile.am \
      -e '/chown root/d' \
      -e '/chmod u/d'
  '';

  meta = with stdenv.lib; {
    description = "PAM module to mount volumes for a user session";
    homepage    = http://pam-mount.sourceforge.net/;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
