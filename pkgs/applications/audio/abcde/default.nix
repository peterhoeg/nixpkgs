{ stdenv
, lib
, fetchurl
, makeWrapper
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
  bins = lib.makeBinPath [ which libcdio-paranoia cddiscid wget vorbis-tools id3v2 eyeD3 lame flac glyr ];
  perl' = perl.withPackages (p: with p; [ MusicBrainz MusicBrainzDiscID ]);

in
stdenv.mkDerivation rec {
  pname = "abcde";
  version = "2.9.3";

  src = fetchurl {
    url = "https://abcde.einval.com/download/abcde-${version}.tar.gz";
    hash = "sha256-BGzQu6eN1LvcvPgv5iWGXGDfNaAFSC3hOmaZxaO4MSQ=";
  };

  patches = [ ./xdg.patch ];

  # FIXME: This package does not support `distmp3', `eject', etc.
  postPatch = ''
    sed -i "s|^[[:blank:]]*prefix *=.*$|prefix = $out|g ;
            s|^[[:blank:]]*etcdir *=.*$|etcdir = $out/etc|g ;
            s|^[[:blank:]]*INSTALL *=.*$|INSTALL = install -c|g" \
      "Makefile";

    substituteInPlace abcde \
      --replace CDPARANOIA=cdparanoia CDPARANOIA=${lib.getBin libcdio-paranoia}/bin/cd-paranoia \
      --replace '#CDROMREADERSYNTAX=cdparanoia' 'CDROMREADERSYNTAX=cdparanoia'
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ perl' ];

  installFlags = [ "sysconfdir=$(out)/etc" ];

  # we need to wrap all, including the perl script as we are not using the perl
  # builder and thus do not automatically inject the dependencies
  postFixup = ''
    for cmd in $out/bin/*; do
      wrapProgram $cmd \
        --prefix PERL5LIB : "$PERL5LIB" \
        --prefix PATH ":" ${bins} \
        --prefix PATH ":" ${lib.makeBinPath ["$out"]}
    done
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
