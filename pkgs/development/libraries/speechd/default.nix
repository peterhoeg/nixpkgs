{ stdenv, lib, fetchurl, autoreconfHook, intltool, pkgconfig, texinfo, writeText
, glib, dotconf, libsndfile
, alsaLib, libao, libpulseaudio, python3Packages
, withEspeak ? false, espeak
, withPico ? true, svox
}:

let
  service = writeText "speechd.service" ''
    [Unit]
    Description=Speech-Dispatcher a high-level device independent layer for speech synthesis

    [Service]
    Type=forking
    RuntimeDirectory=speech-dispatcher
    # We set --log-dir to something which isn't a directory so speechd is forced to log to stdout
    ExecStart=@out@/bin/speech-dispatcher --run-daemon --timeout 0 --pid-file %t/speech-dispatcher/pid --log-dir /dev/stdout
    PIDFile=%t/speech-dispatcher/pid
    Restart=on-failure
    PrivateTmp=true
  '';

in stdenv.mkDerivation rec {
  name = "speech-dispatcher-${version}";
  version = "0.8.7";

  src = fetchurl {
    url = "http://www.freebsoft.org/pub/projects/speechd/${name}.tar.gz";
    sha256 = "0d5i9ig2di8jffcgnhrkl6x4l3bwdan9irs6pjzi9paln2ny22r0";
  };

  buildInputs = [
    glib dotconf libsndfile python3Packages.python intltool
    alsaLib libao libpulseaudio
  ] ++ lib.optional withEspeak espeak
    ++ lib.optional withPico   svox;

  nativeBuildInputs = [ autoreconfHook pkgconfig python3Packages.wrapPython texinfo ];

  enableParallelBuilding = true;

  # hardeningDisable = [ "format" ];

  pythonPath = with python3Packages; [ pyxdg ];

  postPatch = lib.optionalString withPico ''
    substituteInPlace src/modules/pico.c \
      --replace /usr/share/pico/lang/ ${svox}/share/pico/lang/
  '';

  postInstall = ''
    mkdir -p $out/lib/systemd/{system,user}

    wrapPythonPrograms

    for d in system user ; do
      substitute ${service} $out/lib/systemd/$d/speechd.service \
        --subst-var out
    done
  '';

  meta = with stdenv.lib; {
    description = "Common interface to speech synthesis";
    homepage    = https://www.freebsoft.org/speechd;
    license     = licenses.gpl2Plus;
    platforms   = platforms.linux;
  };
}
