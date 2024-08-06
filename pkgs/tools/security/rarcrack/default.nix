{ lib, stdenv, fetchFromGitHub, libxml2, file, p7zip, unrar, unzip }:

stdenv.mkDerivation {
  pname = "rarcrack";
  version = "0.2.20231004";

  src = fetchFromGitHub {
    owner = "jaredsburrows";
    repo = "Rarcrack";
    rev = "278b34c99f486feecfc654abb3af64ac394cec35";
    hash = "sha256-6q66OKpb1RnDiV05V3OJ/MxgW8/rQ7SIaSF+JfN8jM0=";
  };

  nativeBuildInputs = [ unzip ];

  buildInputs = [ libxml2 file p7zip unrar ];

  buildFlags = lib.optional stdenv.cc.isClang "CC=clang";

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  postPatch = ''
    substituteInPlace rarcrack.c \
      --replace "file -i" "${file}/bin/file -i"
  '';

  preInstall = ''
    mkdir -p $out/bin
  '';

  meta = with lib; {
    description = "This program can crack zip,7z and rar file passwords";
    longDescription = ''
      If you forget your password for compressed archive (rar, 7z, zip), this program is the solution.
      This program uses bruteforce algorithm to find correct password. You can specify wich characters will be used in password generations.
      Warning: Please don't use this program for any illegal things!
    '';
    homepage = "https://github.com/jaredsburrows/Rarcrack";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ davidak ];
    platforms = with platforms; unix;
  };
}

