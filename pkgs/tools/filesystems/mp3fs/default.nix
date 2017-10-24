{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, asciidoc, libxslt
, flac, fuse, lame, libid3tag }:

stdenv.mkDerivation rec {
  name = "mp3fs-${version}";
  version = "0.91";

  src = fetchFromGitHub {
    owner  = "khenriks";
    repo   = "mp3fs";
    rev    = "v${version}";
    sha256 = "0hhrvqd96zpabs8nvychhjxrwy6z4180c2dvalwvrx6q7fhscqlv";
  };

  patches = [ ./fix-statfs-operation.patch ];

  postPatch = ''
    substituteInPlace Makefile.am \
      --replace a2x 'a2x --no-xmllint'
  '';

  buildInputs = [ flac fuse lame libid3tag ];

  nativeBuildInputs = [ asciidoc autoreconfHook libxslt.bin pkgconfig ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "FUSE file system that transparently transcodes to MP3";
    longDescription = ''
      A read-only FUSE filesystem which transcodes between audio formats
      (currently only FLAC to MP3) on the fly when files are opened and read.
      It can let you use a FLAC collection with software and/or hardware
      which only understands the MP3 format, or transcode files through
      simple drag-and-drop in a file browser.
    '';
    homepage    = https://khenriks.github.io/mp3fs/;
    license     = licenses.gpl3Plus;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ nckx ];
  };
}
