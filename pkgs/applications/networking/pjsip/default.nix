{ stdenv, fetchurl, autoreconfHook, pkgconfig
, automake, autoconf
, alsaLib, openssl, libopus, libsamplerate, portaudio, speex, srtp }:

stdenv.mkDerivation rec {
  name = "pjsip-${version}";
  version = "2.7";

  src = fetchurl {
    url    = "http://www.pjsip.org/release/${version}/pjproject-${version}.tar.bz2";
    sha256 = "0swgn821nc5m4fcrwbxv2b3iy0zgr2mhc7siqarm34f324d6500w";
  };

  hardeningDisable = [ "pic" ];

  postPatch = ''
    mv aconfigure    configure
    mv aconfigure.ac configure.ac
  '';

  configureFlags = [
    "--with-external-pa"
    "--with-external-speex"
    "--with-external-srtp"
  ];

  buildInputs = [ alsaLib openssl libopus libsamplerate portaudio speex srtp ];

  nativeBuildInputs = [ autoconf automake pkgconfig ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/{bin,share/${name}/samples}

    cp pjsip-apps/bin/pjsua-*     $out/bin/pjsua
    cp pjsip-apps/bin/samples/*/* $out/share/${name}/samples
  '';

  doCheck = true;

  # We need the libgcc_s.so.1 loadable (for pthread_cancel to work)
  dontPatchELF = true;

  meta = with stdenv.lib; {
    description = "A multimedia communication library written in C, implementing standard based protocols such as SIP, SDP, RTP, STUN, TURN, and ICE";
    homepage    = https://pjsip.org/;
    license     = stdenv.lib.licenses.gpl2Plus;
    maintainers = with maintainers; [ viric ];
    platforms   = with platforms; linux;
  };
}
