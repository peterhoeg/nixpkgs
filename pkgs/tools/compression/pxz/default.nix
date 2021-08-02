{ lib, stdenv, fetchFromGitHub, xz }:

stdenv.mkDerivation rec {
  pname = "pxz";
  version = "4.999.9beta+git";

  src = fetchFromGitHub {
    owner = "jnovy";
    repo = "pxz";
    rev = "124382a6d0832b13b7c091f72264f8f3f463070a";
    sha256 = "15mmv832iqsqwigidvwnf0nyivxf0y8m22j2szy4h0xr76x4z21m";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace '`date +%Y%m%d`' '1970-01-01'
  '';

  buildInputs = [ xz ];

  makeFlags = [
    "BINDIR=${placeholder "out"}/bin"
    "MANDIR=${placeholder "out"}/share/man"
  ];

  meta = with lib; {
    homepage = "https://jnovy.fedorapeople.org/pxz/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ pashev ];
    description = "compression utility that runs LZMA compression of different parts on multiple cores simultaneously";
    longDescription = ''
      Parallel XZ is a compression utility that takes advantage of
      running LZMA compression of different parts of an input file on multiple
      cores and processors simultaneously. Its primary goal is to utilize all
      resources to speed up compression time with minimal possible influence
      on compression ratio
    '';
    platforms = with platforms; linux;
  };
}
