{ stdenv, fetchurl, fetchpatch, autoconf, automake, perl, pkgconfig, python2Packages, which
, gnutls, gnome2 }:

# wmi doesn't compile out of the box on recent versions of GCC.
#
# If someone takes a stab, I suggest having a look at this for starters:
# https://gcc.gnu.org/gcc-4.8/porting_to.html
# NIX_CFLAGS_COMPILE = [ "-ffreestanding" ];
# http://www.edcint.co.nz/checkwmiplus/?q=faq_wmicwontcompile1

let
  url = "http://www.openvas.org/download/wmi";

in stdenv.mkDerivation rec {
  name = "wmi-${version}";
  version = "1.3.14";

  src = fetchurl {
    url    = "${url}/${name}.tar.bz2";
    sha256 = "0zmg9brfidza3y7l9fz182gg70rrm90wl478k34k5m0mj92hssv7";
  };

  patches = [
    (fetchpatch {
      url = "${url}/openvas-wmi-1.3.14.patch";
      sha256 = "0gnqka2q1f50gg0wxbkr3rlqn6xn7nsc225x3fpcxjmhxbn092kj";
    })
    (fetchpatch {
      url = "${url}/openvas-wmi-1.3.14.patch2";
      sha256 = "1rq8zz6jph6d64kcmfy0pn6hz4nz2jxrh0cm10va84h3swy6y8r3";
    })
    (fetchpatch {
      url = "${url}/openvas-wmi-1.3.14.patch3v2";
      sha256 = "02a1miylf02l581lx1a81czf5iy4bbr8dvf5vrlqyli5ckrai1a9";
    })
    (fetchpatch {
      url = "${url}/openvas-wmi-1.3.14.patch4";
      sha256 = "1qmghkrpymyh2d4scgc4wqljll41pc0qpb2a0jrdrg9aqjiywa1y";
    })
    (fetchpatch {
      url = "${url}/openvas-wmi-1.3.14.patch5";
      sha256 = "0c4m5fv7w6ijcr9pngznlicwmp4pz541rpjhf93d4l4svjk8322c";
    })
    ./fix_gnutls.patch
  ];

  postPatch = ''
    sed -i Samba/source/pidl/pidl -e '583d'
    patchShebangs .
  '';

  hardeningDisable = [ "stackprotector" "format" ];

  nativeBuildInputs = [ autoconf automake perl pkgconfig python2Packages.python which ];

  buildInputs = [ gnutls gnome2.GConf ];

  enableParallalBuilding = true;

  preConfigure = ''
    export ZENHOME=$out
  '';

  meta = with stdenv.lib; {
    description = "WMI (Windows Management Instrumentation) client";
    homepage    = url;
    license     = licenses.asl20;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
