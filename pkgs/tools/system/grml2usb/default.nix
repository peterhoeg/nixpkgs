{ stdenv, lib, fetchFromGitHub, asciidoc, docbook_xsl_ns, makeWrapper, libxslt
, grub2, python2, syslinux, xorriso }:

stdenv.mkDerivation rec {
  name = "grml2usb-${version}";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner  = "grml";
    repo   = "grml2usb";
    rev    = "v${version}";
    sha256 = "0yaykjv26812vdch8vqj8il34hagb4ngnvscxbd917kwchfqk2ph";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/share/xml/docbook/stylesheet/nwalsh/ \
                ${docbook_xsl_ns}/xml/xsl/docbook/

    substituteInPlace grml2iso \
      --replace '$0'    grml2iso
    substituteInPlace grml2usb \
      --replace '%prog' grml2usb \
      --replace '/usr/bin/env python' ${python2.interpreter}
  '';

  nativeBuildInputs = [ asciidoc docbook_xsl_ns makeWrapper libxslt ];

  preBuild = ''
    pushd mbr
    make
    popd
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin                grml2{iso,usb}
    install -Dm644 -t $out/share/man/man8     grml*.8
    install -Dm644 -t $out/share/grml2usb/mbr mbr/mbr{ldr,mgr,mgr.elf}
    cp -r grub/       $out/share/grml2usb/

    runHook postInstall
  '';

  postFixup = ''
    for f in $out/bin/* ; do
      wrapProgram $f \
        --prefix PATH : ${lib.makeBinPath [ grub2 syslinux xorriso ]}
    done
  '';

  meta = with stdenv.lib; {
    description = "Install Grml system to USB devices";
    homepage = https://www.grml.org;
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
