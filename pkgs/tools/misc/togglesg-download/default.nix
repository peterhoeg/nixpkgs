{ stdenv, lib, fetchFromGitHub, buildPythonApplication, makeWrapper, ffmpeg_3 }:

buildPythonApplication rec {

  name = "togglesg-download-git-${version}";
  version = "2016-09-11";

  src = fetchFromGitHub {
    owner = "0x776b7364";
    repo = "toggle.sg-download";
    rev = "790ff01771e3977d9b4421896b9eee369401baf3";
    sha256 = "1j2fkfy5b005jmvs7i9swqrsm89ndqrdqdilaqy55sbhj14dmxym";
  };

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    substitute $src/download_toggle_video2.py $out/bin/download_toggle_video2.py \
      --replace "ffmpeg_download_cmd = 'ffmpeg" "ffmpeg_download_cmd = '${lib.getBin ffmpeg_3}/bin/ffmpeg"
    chmod 0755 $out/bin/download_toggle_video2.py
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
    maintainers = [ maintainers.peterhoeg ];
  };
}
