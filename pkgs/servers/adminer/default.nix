{ stdenv, fetchFromGitHub, libbsd, phpPackages, php }:

stdenv.mkDerivation rec {
  pname = "adminer";
  version = "4.7.8";

  src = fetchFromGitHub {
    owner = "vrana";
    repo = "adminer";
    rev = "v${version}";
    sha256 = "sha256-rfrkybpO58SABIrcI21iRY7QGGU8lcBlNedOWqYvYbQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with phpPackages; [ php composer ];

  buildPhase = ''
    composer --no-cache run compile
  '';

  installPhase = ''
    install -Dm444 adminer-${version}.php $out/adminer.php
  '';

  meta = with stdenv.lib; {
    description = "Database management in a single PHP file";
    homepage = "https://www.adminer.org";
    license = with licenses; [ asl20 gpl2 ];
    maintainers = with maintainers; [ sstef ];
    platforms = platforms.all;
  };
}
