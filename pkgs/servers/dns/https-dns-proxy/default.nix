{ stdenv
, fetchFromGitHub
, cmake
, c-ares
, curl
, libev
}:

stdenv.mkDerivation rec {
  pname = "https_dns_proxy";
  # there are no stable releases (yet?)
  version = "git-20200301";

  src = fetchFromGitHub {
    owner = "aarond10";
    repo = pname;
    rev = "a8dbe9279267df6032122df51ef70a1c1e8d281f";
    sha256 = "17qmqpg9ns2yamlnaaq3a14kqc00cr2i54hw5cxx50risqxm7cdj";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ c-ares curl libev ];

  installPhase = ''
    install -Dm555 -t $out/bin ${pname}
    install -Dm444 -t $out/share/doc/${pname} ../{LICENSE,README}.*
  '';

  meta = with stdenv.lib; {
    description = "DNS to DNS over HTTPS (DoH) proxy";
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
