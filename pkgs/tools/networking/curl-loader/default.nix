{ stdenv, fetchurl, c-ares, curl, libevent, openssl, zlib }:

let
  pname = "curl-loader";

in stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  version = "0.56";

  src = fetchurl {
    url = "mirror://sourceforge/project/${pname}/${pname}-stable/${name}/${name}.tar.bz2";
    sha256 = "0915jibf2k10afrza72625nsxvqa2rp1vyndv1cy7138mjijn4f2";
  };

  buildInputs = [ c-ares curl libevent openssl zlib ];

  preConfigure = ''
    patchShebangs .
    # rm -rf packages/{c-ares,libevent}*
    rm -rf packages
    mkdir -p build
    ln -s ${c-ares.out}   build/c-ares
    # ln -s ${curl.out}     build/curl
    ln -s ${libevent.out} build/libevent

    sed -i Makefile -e 's,$(TARGET): $(LIBCARES) $(LIBCURL) $(LIBEVENT),$(TARGET): ,'
  '';

  configureFlags = [
    "--with-ssl=${openssl.dev}"
    # "--with-zlib=${zlib.dev}"
  ];

  meta = with stdenv.lib; {
    description = "HTTP load tester";
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}
