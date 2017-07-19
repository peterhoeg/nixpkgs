{ stdenv, lib, fetchFromGitHub
, coreutils, gnused, getopt, git, tree, gnupg, which, procps, qrencode
, makeWrapper

, xclip ? null, xdotool ? null, dmenu ? null
, x11Support ? !stdenv.isDarwin
}:

with lib;

assert x11Support -> xclip   != null
                  && xdotool != null
                  && dmenu   != null;

let
  plugins = map (p: (fetchFromGitHub {
    owner  = "roddhjav";
    repo   = "pass-${p.name}";
    inherit (p) rev sha256;
  })) [
    { name = "import"; rev = "8850b9637217c64dedd1fb059c06bf9d9c5e6de2"; sha256 = "0vfmf405yi6z4s6w23ay6m4krgkwq1rxqw616msjqkikqsffv03l"; }
    { name = "tomb";   rev = "v1.0";                                     sha256 = "1zzp7wrmznw90ad4pnbkffwrvqzbwpkvk6vl1b9hgiv6xvqx023f"; }
    { name = "update"; rev = "4d917b805f3ab740e15bdcac84684eb3ca3e5738"; sha256 = "0v01prflxjf1kln39ak7g6nlwhvi2d69v0yrcdykp1xf4y9jk7rs"; }
  ];

in stdenv.mkDerivation rec {
  version = "1.7.1";
  name    = "password-store-${version}";

  src = fetchFromGitHub {
    owner  = "zx2c4";
    repo   = "password-store";
    rev    = "${version}";
    sha256 = "04rqph353qfhnrwji6fmvrbk4yag8brqpbpaysq5z0c9l4p9ci87";
  };

  patches = [
    ./set-correct-program-name-for-sleep.patch
  ] ++ stdenv.lib.optional stdenv.isDarwin ./no-darwin-getopt.patch;

  nativeBuildInputs = [ makeWrapper ];

  installFlags = [ "PREFIX=$(out)" "WITH_ALLCOMP=yes" ];

  postInstall = ''
    # plugins
    ${stdenv.lib.concatStringsSep "\n" (map (plugin: ''
      pushd ${plugin}
      PREFIX=$out make install
      popd
    '') plugins)}

    # Install Emacs Mode. NOTE: We can't install the necessary
    # dependencies (s.el and f.el) here. The user has to do this
    # himself.
    mkdir -p "$out/share/emacs/site-lisp"
    cp "contrib/emacs/password-store.el" "$out/share/emacs/site-lisp/"
  '' + optionalString x11Support ''
    cp "contrib/dmenu/passmenu" "$out/bin/"
  '';

  wrapperPath = stdenv.lib.makeBinPath ([
    coreutils
    getopt
    git
    gnupg
    gnused
    tree
    which
    qrencode
  ] ++ stdenv.lib.optional stdenv.isLinux procps
    ++ ifEnable x11Support [ dmenu xclip xdotool ]);

  postFixup = ''
    # Fix program name in --help
    substituteInPlace $out/bin/pass \
      --replace 'PROGRAM="''${0##*/}"' "PROGRAM=pass"

    # we wrap everything we find although probably not necessary for passmenu
    for f in $out/bin/* ; do
      wrapProgram $f \
        --prefix PATH : "$out/bin:${wrapperPath}"
    done
  '';

  meta = with stdenv.lib; {
    description = "Stores, retrieves, generates, and synchronizes passwords securely";
    homepage    = http://www.passwordstore.org/;
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ lovek323 the-kenny fpletz ];
    platforms   = platforms.unix;

    longDescription = ''
      pass is a very simple password store that keeps passwords inside gpg2
      encrypted files inside a simple directory tree residing at
      ~/.password-store. The pass utility provides a series of commands for
      manipulating the password store, allowing the user to add, remove, edit,
      synchronize, generate, and manipulate passwords.
    '';
  };
}
