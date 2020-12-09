{ stdenv, fetchurl, fetchFromGitHub, php, which, makeWrapper, bash, coreutils, ncurses }:
let
  consoleTable = fetchurl {
    url = "http://download.pear.php.net/package/Console_Table-1.1.3.tgz";
    sha256 = "07gbjd7m1fj5dmavr0z20vkqwx1cz2522sj9022p257jifj1yl76";
  };

  path = stdenv.lib.makeBinPath [ which php bash coreutils ncurses ];

in
stdenv.mkDerivation rec {
  pname = "drush";
  version = "10.3.6";

  src = fetchFromGitHub {
    owner = "drush-ops";
    repo = "drush";
    rev = version;
    sha256 = "sha256-45I0ys8PONlvYA6iXDK5ehUtI5BKCDhNsCoqXw5nIfw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    # install libraries
    # tar -xf ${consoleTable} -C lib

    mkdir -p $out/bin
    cp -r . $out/src
    wrapProgram $out/src/drush \
      --prefix PATH : ${path}
    ln -s "$out/src/drush" "$out/bin/drush"
  '';

  meta = with stdenv.lib; {
    description = "Command-line shell and Unix scripting interface for Drupal";
    homepage = "https://github.com/drush-ops/drush";
    license = licenses.gpl2;
    maintainers = with maintainers; [ lovek323 ];
    platforms = platforms.all;
  };
}
