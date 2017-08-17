{ stdenv, fetchurl, fetchpatch, libpcap, pkgconfig, openssl
, graphicalSupport ? false
, libX11 ? null
, gtk2 ? null
, withPython ? false # required for the `ndiff` binary
, python2Packages ? null
, makeWrapper ? null
}:

assert withPython -> python2Packages != null;

with stdenv.lib;

let

  # Zenmap (the graphical program) also requires Python,
  # so automatically enable pythonSupport if graphicalSupport is requested.
  pythonSupport = withPython || graphicalSupport;

in stdenv.mkDerivation rec {
  name = "nmap${optionalString graphicalSupport "-graphical"}-${version}";
  version = "7.60";

  src = fetchurl {
    url = "https://nmap.org/dist/nmap-${version}.tar.bz2";
    sha256 = "08bga42ipymmbxd7wy4x5sl26c0ir1fm3n9rc6nqmhx69z66wyd8";
  };

  patches = [
    ./zenmap.patch
    (fetchpatch {
      url = "https://dev.solus-project.com/source/nmap/browse/master/files/0001-zenmap-Use-pkexec-to-gain-root-privileges.patch?view=raw";
      sha256 = "1g8iak264igjwk6drc8q8pgp5r7dg5i8s6p8i650bppyjmhnsrn1";
    })
  ];

  pythonPath = [] ++ stdenv.lib.optionals graphicalSupport (with python2Packages; [
    pycairo
    pygobject2
    pygtk
  ]);

  prePatch = ''
    ${optionalString stdenv.isDarwin ''
      substituteInPlace libz/configure \
          --replace /usr/bin/libtool ar \
          --replace 'AR="libtool"' 'AR="ar"' \
          --replace 'ARFLAGS="-o"' 'ARFLAGS="-r"'
    ''};

    substituteInPlace zenmap/setup.py \
      --replace /usr/share $out/share

    #  --replace /usr/bin/zenmap $out/bin/zenmap
    substituteInPlace zenmap/install_scripts/unix/org.nmap.zenmap.pkexec.policy \
       --replace /usr/bin /run/current-system/sw/bin
  '';

  buildInputs = with python2Packages; [ libpcap openssl ]
    ++ optionals pythonSupport [ python ]
    ++ optionals graphicalSupport [
      libX11 gtk2 pygtk pysqlite pygobject2 pycairo
    ];

  nativeBuildInputs = [
    makeWrapper pkgconfig python2Packages.wrapPython
  ];

  enableParallelBuilding = true;

  configureFlags = []
    ++ optional (!pythonSupport)    "--without-ndiff"
    ++ optional (!graphicalSupport) "--without-zenmap"
  ;

  postInstall = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  meta = {
    description = "A free and open source utility for network discovery and security auditing";
    homepage    = http://www.nmap.org;
    license     = licenses.gpl2;
    platforms   = platforms.all;
    maintainers = with maintainers; [ mornfall thoughtpolice fpletz ];
  };
}
