{ stdenv
, lib
, fetchurl
, resholve
  # , buildPerlModule
, bash
, perl
, cddiscid
, eyeD3
, flac
, glyr
, id3v2
, lame
, libcdio-paranoia
, vorbis-tools
, wget
, which
}:

let

  version = "2.9.3";

  src = fetchurl {
    url = "https://abcde.einval.com/download/abcde-${version}.tar.gz";
    hash = "sha256-BGzQu6eN1LvcvPgv5iWGXGDfNaAFSC3hOmaZxaO4MSQ=";
  };

  musicbrainz = perlEnv.pkgs.buildPerlModule rec {
    pname = "abcde-musicbrainz-tool";
    inherit version src;

    outputs = [ "out" ];

    postPatch = ''
      substituteInPlace Makefile \
        --replace /usr/bin/install install \
        --replace /usr/local $out \
        --replace /etc $out/etc/abcde
    '';

    dontBuild = true;
    doCheck = false;

    installPhase = ''
      make install
    '';

  };

  perlEnv = perl.withPackages (p: with p; [ MusicBrainz MusicBrainzDiscID ]);

in
resholve.mkDerivation rec {
  pname = "abcde";

  inherit version src;

  patches = [ ./xdg.patch ];

  postPatch = ''
    sed -i "s|^[[:blank:]]*prefix *=.*$|prefix = $out|g ;
            s|^[[:blank:]]*etcdir *=.*$|etcdir = $out/etc|g ;
            s|^[[:blank:]]*INSTALL *=.*$|INSTALL = install -c|g" \
      "Makefile";
  '';


  installFlags = [ "sysconfdir=$(out)/etc" ];

  # [ which libcdio-paranoia cddiscid wget vorbis-tools id3v2 eyeD3 lame flac glyr ];
  solutions = {
    abcde = {
      scripts = [ "bin/abcde" ];
      interpreter = lib.getExe bash;
      inputs = [ ];
    };
    cddb = {
      scripts = [ "bin/cddb-tool" ];
      interpreter = lib.getExe bash;
      inputs = [ ];
    };
  };

  postInstall = ''
    ln -sf ${musicbrainz}/bin/abcde-musicbrainz-tool $out/bin/abcde-musicbrainz-tool
  '';

  meta = with lib; {
    description = "Command-line audio CD ripper";
    homepage = "https://abcde.einval.com/wiki/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ gebner ];
    longDescription = ''
      abcde is a front-end command-line utility (actually, a shell
      script) that grabs tracks off a CD, encodes them to
      Ogg/Vorbis, MP3, FLAC, Ogg/Speex and/or MPP/MP+ (Musepack)
      format, and tags them, all in one go.
    '';
    platforms = platforms.linux;
  };
}
