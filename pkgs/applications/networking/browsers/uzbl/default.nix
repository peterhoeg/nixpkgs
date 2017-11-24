{ stdenv, fetchFromGitHub, pkgconfig, python3, makeWrapper
, webkit, glib_networking, gnutls, gsettings_desktop_schemas, python2Packages
}:

# This package needs python3 during buildtime,
# but Python 2 + packages during runtime.

stdenv.mkDerivation rec {
  name = "uzbl-${version}";
  version = "20170902";

  src = fetchFromGitHub {
    owner = "uzbl";
    repo = "uzbl";
    rev = "676b47e36a03a9ad07f13589e44875800a1878f9";
    sha256 = "0yx9mxhhpfk6lp4va1gd4q3fsi0y99bz68y3yvy8a5lndhpl0xvj";
  };

  nativeBuildInputs = [ makeWrapper pkgconfig python3 ];

  buildInputs = [ gnutls gsettings_desktop_schemas webkit ];

  propagatedBuildInputs = with python2Packages; [ pygtk six ];

  format = "other";

  enableParallelBuilding = true;

  configureFlags = [
    "PREFIX=$out"
    "PYINSTALL_EXTRA=--prefix=$out"
  ];

  preConfigure = ''
    mkdir -p $out/${python2Packages.python.sitePackages}/
    export PYTHONPATH=$PYTHONPATH:$out/${python2Packages.python.sitePackages}
  '';

  installPhase = ''
    exit 1
    runHook preInstall
    make install
    runHook postInstall
  '';

  preFixup = ''
    for f in $out/bin/*; do
      wrapProgram $f \
        --prefix GIO_EXTRA_MODULES : "${glib_networking.out}/lib/gio/modules" \
        --prefix PYTHONPATH : "$PYTHONPATH" \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:$out/share"
    done
  '';

  meta = with stdenv.lib; {
    description = "Tiny externally controllable webkit browser";
    homepage    = "http://uzbl.org/";
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ raskin dgonyeo ];
  };

}
