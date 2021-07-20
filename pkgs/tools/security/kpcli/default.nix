{ lib, stdenv, fetchurl, makeWrapper, perlPackages }:

perlPackages.buildPerlPackage rec {
  version = "3.6";
  pname = "kpcli";

  src = fetchurl {
    url = "mirror://sourceforge/kpcli/${pname}-${version}.pl";
    sha256 = "1srd6vrqgjlf906zdyxp4bg6gihkxn62cpzyfv0zzpsqsj13iwh1";
  };

  postPatch = ''
    echo -e "install:\n\t@install -Dm555 ${src} $out/libexec/kpcli.pl" > Makefile.PL

    ln -s Makefile.PL Makefile
  '';

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  outputs = [ "out" ];

  buildInputs = with perlPackages; ([
    CaptureTiny
    Clipboard
    Clone
    CryptRijndael
    FileKeePass
    SortNaturally
    TermReadKey
    TermReadLineGnu
    TermShellUI
    XMLParser
  ] ++ lib.optional stdenv.isDarwin MacPasteboard);

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    makeWrapper $out/libexec/kpcli.pl $out/bin/kpcli \
      --prefix PERL5LIB : $PERL5LIB
  '';

  meta = with lib; {
    description = "KeePass Command Line Interface";
    longDescription = ''
      KeePass Command Line Interface (CLI) / interactive shell.
      Use this program to access and manage your KeePass 1.x or 2.x databases from a Unix-like command line.
    '';
    license = licenses.artistic1;
    homepage = "http://kpcli.sourceforge.net";
    maintainers = with maintainers; [ j-keck ];
    platforms = platforms.all;
  };
}
