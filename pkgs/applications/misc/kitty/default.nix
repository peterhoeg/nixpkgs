{ stdenv, fetchFromGitHub, python3, pkgconfig
, fontconfig, freetype, glfw3, glew, libpng, libunistring, ncurses, zlib }:

python3.pkgs.buildPythonApplication rec {
  name = "kitty-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "kitty";
    rev = "v${version}";
    sha256 = "0k9c1xigz3vfmdbd0xmlryxzbgzs6synm3jxv46nnrbkd8pah29x";
  };

  format = "other";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ fontconfig freetype glew glfw3 libpng libunistring ncurses python3 zlib ];

  propagatedBuildInputs = with python3.pkgs; [
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    python3 setup.py linux-package --prefix=$out

    # mkdir -p $out
    # mv linux-package/{bin,lib,share} $out

    runHook postInstall
  '';

  doCheck = false;

  installCheckPhase = ''
    runHook preInstallCheck

    export HOME=tmp

    python3 setup.py test

    runHook postInstallCheck
  '';

  meta = with stdenv.lib; {
    homepage    = https://github.com/kovidgoyal/kitty;
    description = "A modern, hackable, featureful, OpenGL based terminal emulator";
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = with platforms; linux ++ darwin;
  };
}
