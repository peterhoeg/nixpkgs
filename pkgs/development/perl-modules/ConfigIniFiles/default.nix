{ stdenv, buildPerlPackage, fetchurl }:

buildPerlPackage rec {
  name = "Config-IniFiles-2.94";

  src = fetchurl {
    url    = "mirror://cpan/authors/id/S/SH/SHLOMIF/${name}.tar.gz";
    sha256 = "1d4la72fpsf61hcpslmn03ajm5rfy8hm50piqmsfi7d7dm0qmlyn";
  };

  propagatedBuildInputs = [ IOStringy ModuleBuild ];

  meta = with stdenv.lib; {
    homepage    = https://github.com/shlomif/perl-Config-IniFiles;
    description = "A module for reading .ini-style configuration files";
    license     = with licenses; [ artistic1 gpl1Plus ];
    maintainers = with maintainers; [ peterhoeg ];
  };
}
