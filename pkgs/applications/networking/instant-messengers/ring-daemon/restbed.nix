{ stdenv, fetchFromGitHub, cmake, patches
, asio, openssl }:

let
  kashmir = fetchFromGitHub {
    owner  = "Corvusoft";
    repo   = "kashmir-dependency";
    rev    = "2f3913f49c4ac7f9bff9224db5178f6f8f0ff3ee";
    sha256 = "0f0x59p0lwxdjmqc4srpzxj67n795l15m88xgzswn49j8cdd0br1";
  };

in stdenv.mkDerivation rec {
  name = "restbed-${version}";
  version = "4.6";

  src = fetchFromGitHub {
    owner  = "Corvusoft";
    repo   = "restbed";
    rev    = version;
    sha256 = "06h4pkrzshxlxyf0473x3bw9x1g8mb7l3hasy1bvqdlip3k47qi2";
  };

  prePatch = ''
    rmdir dependency/kashmir
    ln -s ${kashmir} dependency/kashmir
  '';

  inherit patches;

  buildInputs = [ asio openssl ];

  nativeBuildInputs = [ cmake ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "HTTP framework for building networked applications";
    longDescription = ''
      HTTP framework for building networked applications that require seamless
      and secure communication, with the flexibility to model a range of
      business processes. Targeting mobile, tablet, desktop, and embedded
      production environments.
    '';
    homepage = https://corvusoft.co.uk/;
    license = licenses.agpl3;
    maintainers = with maintainers; [ taeer ];
    platforms = platforms.linux;
  };
}
