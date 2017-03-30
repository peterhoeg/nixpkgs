{ stdenv, fetchFromGitHub, cmake, extra-cmake-modules
, qtbase, qtmultimedia, qtwebsockets }:

stdenv.mkDerivation rec {
  name = "snorenotify-${version}";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner  = "KDE";
    repo   = "snorenotify";
    rev    = "v${version}";
    sha256 = "0i425i9xli0jvi3gpjvrb9hlmavv8ldf4znl6vvqfip2m1dkzdmr";
  };

  buildInputs = [ qtbase qtmultimedia qtwebsockets ];
  nativeBuildInputs = [ cmake extra-cmake-modules ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-Wno-dev" # the build is otherwise quite noisy
  ];

  meta = with stdenv.lib; {
    description = "A multi platform Qt notification framework.";
    longDescription = ''
      Using a plugin system it is possible to create notifications with many
      different notification systems on Windows, Mac OS and Unix and mobile
      Devices.
    '';
    homepage = http://github.com/KDE/snorenotify;
    license = licenses.bsd3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
