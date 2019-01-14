{ stdenv, fetchurl, python3Packages, glibcLocales, fetchpatch }:

let
  inherit (python3Packages) buildPythonApplication buildPythonPackage fetchPypi;

  num2words = buildPythonPackage rec {
    pname = "num2words";
    version = "0.5.9";
    src = fetchPypi {
      inherit pname version;
      sha256 = "111c5w5139nlbnzgsi6k3smqrayhspgpwd4axf6ns1znrymrr7jf";
    };
    # propagatedBuildInputs = with python3Packages; [
      # python-stdnum
      # zeep
    # ];
    # tries external connections
    # doCheck = false;
  };

  vatnumber = buildPythonPackage rec {
    pname = "vatnumber";
    version = "1.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0yrc5w5139nlbnzgsi6k3smqrayhspgpwd4axf6ns1znrymrr7jf";
    };
    propagatedBuildInputs = with python3Packages; [
      python-stdnum
      zeep
    ];
    # tries external connections
    doCheck = false;
  };

in buildPythonApplication rec {
  pname = "odoo";
  version = "12.0";

  src = fetchurl {
    url = "https://download.odoocdn.com/${version}/nightly/src/odoo_${version}.latest.tar.gz";
    sha256 = "1ji2kz22mx55px5xpagqis83grgadwdcx8dy71v7yk2c0b5r3j6b";
  };

  postPatch = ''
    sed -i \
      -e 's@pyldap.*@ldap3@i' \
      requirements.txt
  '';

  buildInputs = [

  ];

  propagatedBuildInputs = with python3Packages; [
    Babel
    chardet
    decorator
    docutils
    # ebaysdk
    feedparser
    gevent
    greenlet
    html2text
    jinja2
    ldap3
    # libsass
    lxml
    Mako
    markupsafe
    mock
    num2words #
    ofxparse
    passlib
    pillow
    psutil
    psycopg2
    pydot
    # pyldap # ldap3 instead
    pyparsing
    pypdf2
    pyserial
    python-dateutil
    pytz
    pyusb
    qrcode
    reportlab
    requests
    suds-jurko
    vatnumber #
    vobject
    werkzeug
    XlsxWriter
    xlwt
    xlrd
  ];

  meta = with stdenv.lib; {
    homepage = https://odoo.com;
    description = "Open Source ERP";
    license = licenses.isc;
    maintainers = with maintainers; [ leenaars ];
    platforms = platforms.linux;
  };
}
