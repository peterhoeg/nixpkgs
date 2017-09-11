{ stdenv, fetchurl, jre, unzip }:

stdenv.mkDerivation rec {
  name = "tabula-${version}";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/tabulapdf/tabula/releases/download/v${version}/tabula-jar-${version}.zip";
    sha256 = "1yn1wa6m5rdhk4grmnycx3i5pzzdlwfx83h944c9g5rqg111111h";
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/tabula
  '';

  meta = with stdenv.lib; {
    description  = "Moneyplex online banking software";
    maintainers  = with maintainers; [ tstrobel ];
    platforms    = platforms.linux;
    license      = licenses.unfree;
  };

}
