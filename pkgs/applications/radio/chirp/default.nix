{ lib
, fetchurl
, python2
}:

python2.pkgs.buildPythonApplication rec {
  pname = "chirp-daily";
  version = "20220408";

  src = fetchurl {
    url = "https://trac.chirp.danplanet.com/chirp_daily/daily-${version}/${pname}-${version}.tar.gz";
    hash = "sha256-MTXmXUf7a0QHEeBfPz7dXKQS+Sdb1brPDtduFR85AUU=";
  };

  propagatedBuildInputs = with python2.pkgs; [
    future
    pygtk
    pyserial
    libxml2
  ];

  meta = with lib; {
    description = "A free, open-source tool for programming your amateur radio";
    homepage = "https://chirp.danplanet.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
