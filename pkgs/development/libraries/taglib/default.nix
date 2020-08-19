{ stdenv, fetchFromGitHub, cmake, fetchpatch
, zlib
}:

# 1.11.1 is the latest official version but has several file corruption and
# security bugs open

stdenv.mkDerivation rec {
  pname = "taglib";
  version = "1.12-beta-1";

  src = fetchFromGitHub {
    owner = "taglib";
    repo = "taglib";
    rev = "v${version}";
    sha256 = "sha256-pPrbt/3X/jSRKpG2pA+X6MkIJBAQZF6a4YhHO6Pg5tY=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ zlib ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];

  meta = with stdenv.lib; {
    homepage = "https://taglib.org/";
    repositories.git = "git://github.com/taglib/taglib.git";
    description = "A library for reading and editing audio file metadata.";
    longDescription = ''
      TagLib is a library for reading and editing the meta-data of several
      popular audio formats. Currently it supports both ID3v1 and ID3v2 for MP3
      files, Ogg Vorbis comments and ID3 tags and Vorbis comments in FLAC, MPC,
      Speex, WavPack, TrueAudio, WAV, AIFF, MP4 and ASF files.
    '';
    license = with licenses; [ lgpl3 mpl11 ];
    inherit (cmake.meta) platforms;
    maintainers = with maintainers; [ ttuegel ];
  };
}
