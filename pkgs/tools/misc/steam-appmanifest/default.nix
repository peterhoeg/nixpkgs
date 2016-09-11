{ stdenv, lib, fetchFromGitHub, buildPythonApplication, pythonPackages, python3, makeWrapper }:

buildPythonApplication rec {

  name = "steam-appmanifest-git-${version}";
  version = "2016-05-31";

  disabled = ! (lib.strings.substring 0 1 pythonPackages.python.majorVersion == "3");

  src = fetchFromGitHub {
    owner = "dotfloat";
    repo = "steam-appmanifest";
    rev = "3e25f9e6425b0fb8682629713fe42dc5599bbd64";
    sha256 = "11ji36zwji2x6n9zivkl6j2v9yf6jlb7x68las3ws8lf0h4bi8mx";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with pythonPackages; [ pygobject3 pygtk ];

  doCheck = false;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp *.py $out/bin
    # chmod 0755 $out/bin/download_toggle_video2.py
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
