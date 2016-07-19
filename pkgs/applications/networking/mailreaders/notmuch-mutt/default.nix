{ stdenv, lib, buildPerlPackage, perlPackages, fetchurl, coreutils, perl, notmuch }:

stdenv.mkDerivation rec {
  version = "0.22";
  name = "notmuch-mutt-${version}";

  buildInputs = [
    notmuch
    perl
  ];

  propagatedBuildInputs = with perlPackages; [
    mailbox

    FileRemove

    DigestSHA1
    MailTools
    StringShellQuote
    TermReadLineGnu
  ];

  outputs = [ "out" ];

  src = notmuch.src;

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    ${coreutils}/bin/install -Dm755 \
      ./contrib/notmuch-mutt/notmuch-mutt \
      $out/bin/notmuch-mutt
  '';

  meta = with lib; {
    description = "Mutt support for notmuch";
    homepage    = http://notmuchmua.org/;
    license     = with licenses; mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
