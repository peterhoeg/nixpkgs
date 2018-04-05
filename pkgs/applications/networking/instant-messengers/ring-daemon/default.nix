{ stdenv, fetchgit, which, autoreconfHook, pkgconfig, automake, libtool
, pjsip, libyamlcpp, alsaLib, libpulseaudio, libsamplerate, libsndfile, dbus
, dbus_cplusplus, ffmpeg, udev, pcre, gsm, speex, boost, opendht, libmsgpack
, gnutls, zlib, jsoncpp, xorg, libargon2, cryptopp, openssl, perl, python3, bash
, libupnp, speexdsp, fetchFromGitHub, cmake, asio }:

let
  myPython = python3.withPackages (ps: with ps; [
    pygobject3
    dbus-python
  ]);

  version = "4.0.9";

  src = fetchgit {
    url = https://gitlab.savoirfairelinux.com/ring/ring-daemon.git;
    rev = "4.0.0";
    sha256 = "1iyfh7yinvr0ww1w8068zci17jp7cz0k4qcrwwb1wmq813dichn8";
  };

  patchdir = "${src}/contrib/src";

  restbed = import ./restbed.nix {
    inherit stdenv fetchFromGitHub cmake asio openssl;
    patches = [
      # "${patchdir}/restbed/strand.patch"
      # "${patchdir}/restbed/dns-resolution-error.patch"
      "${patchdir}/restbed/string.patch"
    ];
  };

  pjsip' = stdenv.lib.overrideDerivation pjsip (old: {
    patches = [
      # "${patchdir}/pjproject/gnutls.patch"
      # ./notestsapps.patch # this one had to be modified
      # "${patchdir}/pjproject/fix_base64.patch"
      "${patchdir}/pjproject/ipv6.patch"
      "${patchdir}/pjproject/ice_config.patch"
      "${patchdir}/pjproject/multiple_listeners.patch"
      "${patchdir}/pjproject/pj_ice_sess.patch"
      "${patchdir}/pjproject/fix_turn_fallback.patch"
      "${patchdir}/pjproject/fix_ioqueue_ipv6_sendto.patch"
      "${patchdir}/pjproject/add_dtls_transport.patch"
    ];
    # CFLAGS = "-g -DPJ_ICE_MAX_CAND=256 -DPJ_ICE_MAX_CHECKS=150 -DPJ_ICE_COMP_BITS=2 -DPJ_ICE_MAX_STUN=3 -DPJSIP_MAX_PKT_LEN=8000";
  });
in
stdenv.mkDerivation rec {
  name = "ring-daemon-${version}";

  inherit src;

  nativeBuildInputs = [
    which
    autoreconfHook
    # automake
    # libtool
    pkgconfig
  ];

  buildInputs = [
    alsaLib boost cryptopp dbus dbus_cplusplus ffmpeg
    gnutls gsm jsoncpp libargon2 libmsgpack libpulseaudio
    libsamplerate libsndfile libupnp libyamlcpp opendht openssl
    pcre perl pjsip' restbed speex speexdsp udev
    xorg.libX11 zlib
  ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir $out/bin
    ln -s $out/lib/ring/dring $out/bin/dring
    cp -R ./tools/dringctrl/ $out/
    substitute ./tools/dringctrl/dringctrl.py $out/dringctrl/dringctrl.py \
      --replace '#!/usr/bin/env python3' "#!${myPython}/bin/python3"
    chmod +x $out/dringctrl/dringctrl.py
    ln -s $out/dringctrl/dringctrl.py $out/bin/dringctrl.py
  '';

  meta = with stdenv.lib; {
    description = "A Voice-over-IP software phone";
    longDescription = ''
      As the SIP/audio daemon and the user interface are separate processes, it
      is easy to provide different user interfaces. GNU Ring comes with various
      graphical user interfaces and even scripts to control the daemon from the
      shell.
    '';
    homepage = https://ring.cx;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ taeer olynch ];
    platforms = platforms.linux;
  };
}
