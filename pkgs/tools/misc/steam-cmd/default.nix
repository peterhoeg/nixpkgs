{ stdenv, lib, fetchurl, makeWrapper, tree }:

stdenv.mkDerivation rec {

  name = "steam-cmd-git-${version}";
  version = "2016-05-31";

  src = fetchurl {
    url = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz";
    sha256 = "1f7rl3mhb6rqxw4w5x6nnv04myv8gyknmz91pdp06i2s3pw85qy7";
  };

  nativeBuildInputs = [ makeWrapper tree ];

  doCheck = false;
  doUnpack = false;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/steamcmd/libexec
    tar xzf $src -C $out
    mv $out/*.sh $out/bin/
    mv $out/linux32 $out/share/steamcmd/libexec
    substituteInPlace $out/bin/steamcmd.sh \
      --replace 'STEAMROOT="$(cd "$${0%/*}" && echo $PWD)"' \
      'STEAMROOT=$out/share/steamcmd/libexec'
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/0x776b7364/toggle.sg-download";
    description = "Command-line tool to download videos from toggle.sg written in Python";
    longDescription = ''
      toggle.sg requires SilverLight in order to view videos. This tool will
      allow you to download the video files for viewing in your media player and
      on your OS of choice.
    '';
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
