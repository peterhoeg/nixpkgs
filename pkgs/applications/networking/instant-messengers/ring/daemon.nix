{ stdenv, fetchgit, autoreconfHook, pkgconfig, makeWrapper

, libyamlcpp, jsoncpp, alsaLib, openssl, libsndfile, libuuid, libpulseaudio, libsamplerate
, ccrtp, libzrtpcpp, dbus, dbus_cplusplus, expat, pcre, gsm, speex, ilbc, libopus
, libtool, gettext, perl, pjsip, restbed, ffmpeg, libudev, libva, cryptopp
, libjack2, boost, glib, dbus_glib, libnotify, intltool }:

stdenv.mkDerivation rec {
  name = "ring-daemon";
  version = "2.1.0";

  src = fetchgit {
    url = "https://gerrit-ring.savoirfairelinux.com/${name}";
    rev = "2b1172219887458af73d7606deb51a5de5ac7933";
    sha256 = "1ik2wc8y1pyzz4wcw8n558g7rp2fyn773wvlvqqnx0lz7063ih42";
  };

  buildInputs = [
    autoreconfHook libyamlcpp jsoncpp alsaLib openssl libuuid
    libsndfile pkgconfig libpulseaudio libsamplerate ccrtp libzrtpcpp dbus
    dbus_cplusplus expat pcre gsm speex ilbc libopus boost libtool gettext
    pjsip restbed libjack2 ffmpeg libudev libva cryptopp
  ];

  meta = with stdenv.lib; {
    homepage = http://ring.cx;
    license = licenses.gpl3Plus;
    description = "Software for universal communication which respects freedoms and privacy of its users (formerly known as SFLphone)";
    # platforms = with platforms; [ linux ];
    maintainers = with maintainers; [ peterhoeg ];
  };
}
