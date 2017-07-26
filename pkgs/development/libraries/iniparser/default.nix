{ stdenv, fetchFromGitHub, doxygen }:

stdenv.mkDerivation rec{
  name = "iniparser-${version}";
  version = "4.0";

  src = fetchFromGitHub {
    owner  = "ndevilla";
    repo   = "iniparser";
    rev    = "v${version}";
    sha256 = "0339qa0qxa5z02xjcs5my8v91v0r9jm4piswrl1sa29kwyxgv5nb";
  };

  nativeBuildInputs = [ doxygen ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace 'LDFLAGS += -Wl,-rpath -Wl,/usr/lib -Wl,-rpath,/usr/lib' ""

    patchShebangs test
  '';

  # TODO: Build dylib on Darwin
  buildFlags = [ "docs" ] ++ (if stdenv.isDarwin then [ "libiniparser.a" ] else [ "libiniparser.so" ]);

  doCheck = true;

  # After v4.0, soname changes to .1
  installPhase = ''
    mkdir -p $out/{include,lib,share/doc/${name}}

    cp src/*.h $out/include

    for i in AUTHORS FAQ* INSTALL LICENSE README* ; do
      bzip2 -c -9 $i > $out/share/doc/${name}/$i.bz2;
    done;
    cp -r html $out/share/doc/${name}
  '' + (if stdenv.isDarwin then ''
    cp libiniparser.a $out/lib
  '' else ''
    cp libiniparser.so.0 $out/lib
    ln -s libiniparser.so.0 $out/lib/libiniparser.so
  '');

  meta = with stdenv.lib; {
    description = "Free standalone ini file parsing library";
    homepage = http://ndevilla.free.fr/iniparser;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
