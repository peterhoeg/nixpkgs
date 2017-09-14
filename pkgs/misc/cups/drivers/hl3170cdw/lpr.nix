{ stdenv, fetchurl, cups, dpkg, ghostscript, patchelf, a2ps, coreutils, gnused, gawk, file, makeWrapper }:

let
  model = "hl3170cdw";

in stdenv.mkDerivation rec {
  name = "${model}-cupswrapper-${version}";
  version = "1.1.2-1";

  src = fetchurl {
    url    = "http://support.brother.com/g/b/files/dlf/dlf007056/${model}lpr-1.1.2-1.i386.deb";
    sha256 = "0jmf3xidj5kifc58hyqyvdq47gxryf4jrmmphlm4xrk1gd0a6l9p";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ cups ghostscript dpkg a2ps ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/{bin,lib/cups/filter,opt}

    dpkg-deb -x $src $out

    substituteInPlace $out/opt/brother/Printers/${model}/lpd/filter${model} \
      --replace /opt "$out/opt" \

    sed -i '/GHOST_SCRIPT=/c\GHOST_SCRIPT=gs' $out/opt/brother/Printers/${model}/lpd/psconvertij2

    patchelf --set-interpreter ${stdenv.glibc.out}/lib/ld-linux.so.2 \
      $out/opt/brother/Printers/${model}/lpd/br${model}filter

    ln -s $out/opt/brother/Printers/${model}/lpd/filter${model} $out/lib/cups/filter/brother_lpdwrapper_${model}

    wrapProgram $out/opt/brother/Printers/${model}/lpd/psconvertij2 \
      --prefix PATH ":" ${ stdenv.lib.makeBinPath [ gnused coreutils gawk ] }

    wrapProgram $out/opt/brother/Printers/${model}/lpd/filter${model} \
      --prefix PATH ":" ${ stdenv.lib.makeBinPath [ ghostscript a2ps file gnused coreutils ] }

    mv $out/usr/bin/* $out/bin
    rmdir $out/usr/bin $out/usr
  '';

  meta = with stdenv.lib; {
    downloadPage = http://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=hl3170cdw_all;
    homepage = http://www.brother.com/;
    description = "Brother HL-3170CDW LPR driver";
    license = licenses.unfree;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
    inherit model;
  };
}
