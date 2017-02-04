{ stdenv, lib, fetchurl, fetchFromGitHub, bzip2, patchelf }:

let
  bt = fetchFromGitHub {
    owner  = "e40";
    repo   = "bittorrent";
    rev    = "7ae052b69aca635be09578d262b845eb46c3ddb2";
    sha256 = "07qydjcz2w4cjbaqa91hgj9dfyii6yczil8hffmcd86cjkzvrh83";
  };

  allegroCL = stdenv.mkDerivation {
    name = "allegro-common-lisp-10.0";

    phases = [ "installPhase" "fixupPhase" ];

    src = fetchurl {
      url = "http://franz.com/ftp/pub/acl100express/linux86/acl100express-linux-x86.bz2";
      sha256 = "1vdaxxnxc4biixqcx89haxhn40zjnbhvqzc81p4xx8nlwdzb0q94";
    };

    buildInputs = [ patchelf ];

    installPhase = ''
      mkdir -p $out
      tar xjf $src --strip-components=1 -C $out

      for f in alisp ; do
        ln -s $out/$f $out/bin/$f
      done

      for f in alisp libacli10041t3.so bin/bundle bin/cvdcvti ; do
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/$f
      done
    '';
  };

in stdenv.mkDerivation rec {
  name = "tget-${version}";
  version = "5.2.2";

  src = fetchFromGitHub {
    owner  = "e40";
    repo   = "tget";
    rev    = "a2c2dfd3eebf8e0df46f8a9a3f131c459c61b459";
    sha256 = "1bbvzk44plhdqnc8bck2k0jbzsdd20zsv1598vngsdd42faiqvsf";
  };

  preConfigure = ''
    sed -i Makefile \
      -e 's, mlisp, alisp,' \
      -e 's, /usr/local, $out,'

    ln -s ${bt} bittorrent
  '';

  buildInputs = [ bt allegroCL ];

  meta = with stdenv.lib; {
    homepage = http://github.com/e40/tget;
    description = "Torrent Get";
    license = licenses.mpl;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
