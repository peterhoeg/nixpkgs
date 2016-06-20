{ stdenv, autoreconfHook, fetchurl, bash, systemd }:

stdenv.mkDerivation rec {
  version = "1.6.4";
  name = "sshguard-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/sshguard/${name}.tar.gz";
    sha1 = "3fsg4si8h8ag8jafrails1rq7g43alri";
  };

  enableParallelBuilding = true;

  buildInputs = [ autoreconfHook ];

  configureFlags = [
    "--prefix=$out"
    "--sbindir=/bin"
    "--with-firewall=iptables"
  ];

  makeFlags = [ "DESTDIR=$out" ];

  postInstall = ''
    mkdir -p $out/bin

    cat > $out/bin/sshguard-journalctl <<_EOF_
      #!${bash}/bin/bash -eu

      SSHGUARD_OPTS=\$1
      shift
      LANG=C ${systemd}/bin/journalctl -afb -p info -n1 -o cat "\$@" | $out/bin/sshguard -l- \$SSHGUARD_OPTS
    _EOF_
  '';

  meta = with stdenv.lib; {
    homepage = http://www.sshguard.net;
    description = "Block attackers automatically at the firewall level";
    platforms = platforms.linux;
    maintainers = [ maintainers.peterhoeg ];
  };
}
