{ stdenv, lib, fetchFromGitHub, cmake, zlib
, withSqlite ? true,  sqlite ? null
, withMysql  ? false, mysql ? null }:

stdenv.mkDerivation rec {
  name = "pvpgn-${version}";
  version = "1.99.7.1-PRO";

  src = fetchFromGitHub {
    owner  = "pvpgn";
    repo   = "pvpgn-server";
    rev    = version;
    sha256 = "0a1byfd3lxwi2zp8wak67jsxvc07985n9x112b9vqncfi4wp4397";
  };

  buildInputs = [ zlib ]
  ++ lib.optional withMysql  mysql
  ++ lib.optional withSqlite sqlite;

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DSHARE_INSTALL_PREFIX=./share" ]
  ++ lib.optional withMysql  "-DWITH_MYSQL=ON"
  ++ lib.optional withSqlite "-DWITH_SQLITE3=ON";

  enableParallelBuilding = true;

  postInstall = ''
    substituteInPlace $out/etc/pvpgn/bnetd.conf \
      --replace $out/var/pvpgn /var/pvpgn
  '';

  meta = with stdenv.lib; {
    description = "Next generation of PvPGN server";
    longDescription = ''
      The PvPGN server acts as a local multi-player server for a number of commercial games.

      This is the successor of "bnetd".
    '';
    homepage = http://github.com/pvpgn;
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
