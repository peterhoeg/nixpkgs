{ stdenv, lib, fetchgit, python3Packages
, docbook2x, docbook_xsl, docbook_xml_dtd_44
, msmtp }:

python3Packages.buildPythonApplication rec {
  name = "smailq-${version}";
  version = "1.2";

  format = "other";

  src = fetchgit {
    url = "https://git.sthu.org/repos/smailq.git";
    rev = "v${version}";
    sha256 = "0d15n8m99bgm6r56xpyjl2iizw6qmlpvjbh8i6wqrgmsba07cqav";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr $out \
      --replace docbook2man.pl ${docbook2x}/bin/docbook2man

    substituteInPlace smailq.docbook \
      --replace /usr/share/xml/docbook/schema/dtd/4.4 ${docbook_xml_dtd_44}/xml/dtd/docbook

    # make the paths follow freedesktop.org recommendations
    substituteInPlace smailq \
      --replace '~/.smailq.conf' '~/.config/smailq.conf' \
      --replace '~/.smailq/log'  '~/.local/share/smailq/log' \
      --replace '~/.smailq/data' '~/.cache/smailq' \
      --replace '/etc/smailq.conf' "$out/etc/smailq.conf"

    substituteInPlace mailq \
      --replace smailq $out/bin/smailq

    substituteInPlace sendmail \
      --replace ' smailq' ' $CMD'
  '';

  preInstall = ''
    mkdir -p $out/{bin,etc,sbin,share/man/man1}

    cat >> $out/etc/smailq.conf << _EOF
    [general]

    [nwtest]

    [msa]
    cmd = ${msmtp}/bin/msmtp
    _EOF
  '';

  nativeBuildInputs = [ docbook2x ];

  meta = with stdenv.lib; {
    description = "A simple mailq for lightweight SMTP clients";
    homepage = src.url;
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
