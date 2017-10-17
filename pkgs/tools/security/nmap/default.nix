{ stdenv, fetchurl, fetchpatch, autoreconfHook, pkgconfig
, libpcap, libssh2, lua, pcre, openssl, zlib
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

  version = "7.60";

  src = fetchurl {
    url = "https://nmap.org/dist/nmap-${version}.tar.bz2";
    sha256 = "08bga42ipymmbxd7wy4x5sl26c0ir1fm3n9rc6nqmhx69z66wyd8";
  };

  libdnet = stdenv.mkDerivation rec {
    name = "nmap-libdnet";

    inherit src;

    configureFlags = [
      "--enable-shared"
    ];

    # nativeBuildInputs = [ autoreconfHook ];

    enableParallelBuilding = true;

    sourceRoot = "nmap-${version}/libdnet-stripped";
  };

in stdenv.mkDerivation rec {
  name = "nmap${optionalString graphicalSupport "-graphical"}-${version}";

  inherit src;

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
    # substituteInPlace zenmap/setup.py \
      # --replace /usr $out

    ${optionalString stdenv.isDarwin ''
      substituteInPlace libz/configure \
          --replace /usr/bin/libtool ar \
          --replace 'AR="libtool"' 'AR="ar"' \
          --replace 'ARFLAGS="-o"' 'ARFLAGS="-r"'
    ''}
  '';

  postPatch = ''
    substituteInPlace zenmap/install_scripts/unix/org.nmap.zenmap.pkexec.policy \
       --replace /usr/bin /run/current-system/sw/bin
  '';

  buildInputs = with python2Packages; [
    # libdnet
    libpcap libssh2 lua openssl pcre zlib
  ] ++ optionals pythonSupport [
    python
  ] ++ optionals graphicalSupport [
    libX11 gtk2 pygtk pysqlite pygobject2 pycairo
  ];

  nativeBuildInputs = [
    makeWrapper pkgconfig python2Packages.wrapPython
  ];

  enableParallelBuilding = true;

  configureFlags = [
    # "--with-libdnet=${libdnet}"
  ] ++ optional (!pythonSupport)    "--without-ndiff"
    ++ optional (!graphicalSupport) "--without-zenmap"
  ;

  makeFlags = [
    "DESTDIR=/"
  ];

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
