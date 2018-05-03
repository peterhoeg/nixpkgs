{ stdenv, lib, fetchgit, cmake, extra-cmake-modules
, plasma-framework, kwindowsystem
, gnupg }:

stdenv.mkDerivation rec {
  name = "pass-plasma-applet-${version}";
  version = "20180502";

  src = fetchgit {
    url    = https://anongit.kde.org/scratch/dvratil/plasma-pass.git;
    rev    = "8c7bb2149e9e723f21b679c3398c24b7e4ccf6b6";
    sha256 = "1n26nsibfkv7yjla5z000h5baldbdbla6wqb802j5byx1fbqc1i2";
  };

  postPatch = ''
    substituteInPlace plugin/passwordprovider.cpp \
      --replace '"gpg2"' '"${lib.getBin gnupg}/bin/gpg2"'
  '';

  nativeBuildInputs = [
    cmake extra-cmake-modules
  ];

  buildInputs = [
    plasma-framework kwindowsystem
  ];

  meta = with stdenv.lib; {
    description = "KDE Plasma 5 widget for controlling pass";
    homepage = src.url;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
