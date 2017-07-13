{ mkDerivation, lib, fetchFromGitLab
, extra-cmake-modules, kdoctools, wrapGAppsHook
, kcrash, kconfig, kinit, kparts
}:

mkDerivation rec {
  name = "kdiff3-${version}";
  version = "1.7.0-2017-06-11";

  src = fetchFromGitLab {
    owner  = "tfischer";
    repo   = "kdiff3";
    rev    = "346496678771b8fbed1cb003d909417e1f7a43f6";
    sha256 = "05a2l1yyzh6dfm0xgp6mzjfbnj0jssmwqfa5092p3gvp7lmq3vbs";
  };

  # postPatch = ''
  #   sed -re "s/(p\\[[^]]+] *== *)('([^']|\\\\')+')/\\1QChar(\\2)/g" -i src/diff.cpp
  # '';

  nativeBuildInputs = [ extra-cmake-modules kdoctools wrapGAppsHook ];

  propagatedBuildInputs = [ kconfig kcrash kinit kparts ];

  meta = with lib; {
    homepage = http://kdiff3.sourceforge.net/;
    license = licenses.gpl2Plus;
    description = "Compares and merges 2 or 3 files or directories";
    maintainers = with maintainers; [ viric peterhoeg ];
    platforms = with platforms; linux;
  };
}
