{ stdenv, lib, fetchurl, libtool, makeWrapper
, coreutils, universal-ctags, ncurses, pythonPackages, sqlite, pkgconfig
}:

stdenv.mkDerivation rec {
  name = "global-${version}";
  version = "6.5.6";

  src = fetchurl {
    url = "mirror://gnu/global/${name}.tar.gz";
    sha256 = "018m536k5y6lks1a6gqn3bsp7r8zk017znqj9kva1nm8d7x9lbqj";
  };

  nativeBuildInputs = [ libtool makeWrapper ];

  buildInputs = [ ncurses ];

  propagatedBuildInputs = [ pythonPackages.pygments ];

  binPath = lib.makeBinPath [ pythonPackages.pygments universal-ctags];

  configureFlags = [
    "--with-ltdl-include=${libtool}/include"
    "--with-ltdl-lib=${libtool.lib}/lib"
    "--with-ncurses=${ncurses.dev}"
    "--with-posix-sort=${coreutils}/bin/sort"
    "--with-sqlite3=${sqlite.dev}"
    "--with-universal-ctags=${universal-ctags}/bin/ctags"
  ];

  doCheck = true;
  enableParallelBuilding = true;

  postInstall = ''
    install -Dm644 *.el $out/share/emacs/site-lisp

    for f in global gtags ; do
      wrapProgram $out/bin/$f \
        --prefix PYTHONPATH ':' $(toPythonPath ${pythonPackages.pygments}) \
        --prefix PATH       ':' ${binPath} \
        --suffix GTAGSCONF  ':' $out/share/gtags/gtags.conf
    done
  '';

  meta = with stdenv.lib; {
    description = "Source code tag system";
    longDescription = ''
      GNU GLOBAL is a source code tagging system that works the same way
      across diverse environments (Emacs, vi, less, Bash, web browser, etc).
      You can locate specified objects in source files and move there easily.
      It is useful for hacking a large project containing many
      subdirectories, many #ifdef and many main() functions.  It is similar
      to ctags or etags but is different from them at the point of
      independence of any editor.  It runs on a UNIX (POSIX) compatible
      operating system like GNU and BSD.
    '';
    homepage = http://www.gnu.org/software/global/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ pSub peterhoeg ];
    platforms = platforms.unix;
  };
}
