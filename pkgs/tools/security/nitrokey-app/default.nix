{ stdenv, cmake, fetchFromGitHub, pkgconfig
, bash-completion, libnitrokey, libusb1, qtbase, qttranslations }:

stdenv.mkDerivation rec {
  name = "nitrokey-app";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = "nitrokey-app";
    rev = "v${version}";
    sha256 = "0mm6vlgxlmpahmmcn4awnfpx5rx5bj8m44cywhgxlmz012x73hzi";
    fetchSubmodules = true;
  };

  # we need libnitrokey > 3.1 before pkgconfig works
  buildInputs = [
    bash-completion
    libnitrokey libusb1
    qtbase qttranslations
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    "-DADD_GIT_INFO=false"
  ];

  meta = with stdenv.lib; {
    description      = "Provides extra functionality for the Nitrokey Pro and Storage";
    longDescription  = ''
       The nitrokey-app provides a QT system tray widget with wich you can
       access the extra functionality of a Nitrokey Storage or Nitrokey Pro.
       See https://www.nitrokey.com/ for more information.
    '';
    homepage         = https://github.com/Nitrokey/nitrokey-app;
    repositories.git = https://github.com/Nitrokey/nitrokey-app.git;
    license          = licenses.gpl3;
    maintainers      = with maintainers; [ kaiha fpletz ];
  };
}
