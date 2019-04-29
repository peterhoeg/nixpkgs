{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mksh";
  version = "57";

  src = fetchFromGitHub {
    owner = "MirBSD";
    repo = pname;
    rev = "${pname}-R${version}";
    sha256 = "1m8s8yxif63p2fvzx28gc4zzixi785bkqzn45kn29h7xwj91hc1q";
  };

  args = lib.concatStringsSep " " [
    "-j"      # parallel
    "-r"      # ?
    "-c lto"  # ?
  ];

  buildPhase = ''
    runHook preBuild

    sh ./Build.sh ${args}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 755 mksh $out/bin/mksh
    install -D -m 644 mksh.1 $out/share/man/man1/mksh.1
    install -D -m 644 dot.mkshrc $out/share/mksh/mkshrc

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "MirBSD Korn Shell";
    longDescription = ''
      The MirBSD Korn Shell is a DFSG-free and OSD-compliant (and OSI
      approved) successor to pdksh, developed as part of the MirOS
      Project as native Bourne/POSIX/Korn shell for MirOS BSD, but
      also to be readily available under other UNIX(R)-like operating
      systems.
    '';
    homepage = https://www.mirbsd.org/mksh.htm;
    license = licenses.bsd3;
    maintainers = with maintainers; [ AndersonTorres joachifm ];
    platforms = platforms.unix;
  };

  passthru = {
    shellPath = "/bin/mksh";
  };
}
