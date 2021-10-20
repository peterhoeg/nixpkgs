{ lib
, mkDerivation
, fetchFromGitLab
, cmake
, extra-cmake-modules
, kdoctools
, libksane
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "skanpage";
  version = "1.0";

  src = fetchFromGitLab {
    owner = "utilities";
    repo = pname;
    rev = version;
    sha256 = "sha256-0zKxNeWbWAH2hZy6q726E2WTIqu7hxQnUu18nuc9VD8=";
    domain = "invent.kde.org";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules kdoctools ];

  buildInputs = [
    libksane
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "KDE multi-page scanning application";
    homepage = "https://apps.kde.org/skanpage";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
