{ stdenv, fetchurl, hl3170cdwlpr, makeWrapper}:

let
  lpr = hl3170cdwlpr;
  inherit (lpr.meta) model;

in stdenv.mkDerivation rec {
  name = "${model}-cupswrapper-${version}";
  version = "1.1.4-0";

  src = fetchurl {
    url = "http://download.brother.com/welcome/dlf006743/${model}_cupswrapper_GPL_source_${version}.tar.gz";
    sha256 = "018h0fivjx8b7n7zm978mcxdyhv1x260w94n421fi4hi4g194w8k";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ lpr ];

  patchPhase = ''
    WRAPPER=cupswrapper/cupswrapper${model}

    substituteInPlace $WRAPPER \
    --replace /opt    "${lpr}/opt" \
    --replace /usr    "${lpr}/usr" \
    --replace /etc    "$out/etc" \
    --replace "\`cp " "\`cp -p " \
    --replace "\`mv " "\`cp -p "
  '';

  buildPhase = ''
    cd brcupsconfig
    make all
    cd ..
  '';

  installPhase = ''
    TARGETFOLDER=$out/opt/brother/Printers/${model}/cupswrapper/
    mkdir -p $out/opt/brother/Printers/${model}/cupswrapper/

    cp brcupsconfig/brcupsconfpt1          $TARGETFOLDER
    cp cupswrapper/cupswrapper${model}     $TARGETFOLDER
    cp PPD/brother_${model}_printer_en.ppd $TARGETFOLDER
  '';

  cleanPhase = ''
    cd brcupsconfig
    make clean
  '';

  meta = with stdenv.lib; {
    description = "Brother HL-3170CDW CUPS wrapper driver";
    inherit (lpr.meta) downloadPage homepage maintainers platforms;
    license = licenses.gpl2;
  };
}
