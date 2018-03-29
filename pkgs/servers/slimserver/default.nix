{ stdenv, buildPerlPackage, fetchFromGitHub
, perl, perlPackages }:

buildPerlPackage rec {
  name = "slimserver-${version}";
  version = "7.9.0";

  src = fetchFromGitHub {
    owner  = "Logitech";
    repo   = "slimserver";
    rev    = version;
    sha256 = "0idfq0bhg6czajwbvxk4vd1wc46c2v9v3mhjx1ri4my9b75qy1dm";
  };

  buildInputs = [ perl ] ++ (with perlPackages; [
    AnyEvent AudioScan CarpClan CGI ClassXSAccessor
    DataDump DataURIEncode DBDSQLite DBI DBIxClass
    DigestSHA1 EV ExporterLite FileBOM FileCopyRecursive
    FileNext FileReadBackwards FileSlurp FileWhich
    HTMLParser HTTPCookies HTTPDaemon HTTPMessage
    ImageScale IOSocketSSL IOString JSONXSVersionOneAndTwo
    Log4Perl LWPUserAgent NetHTTP ProcBackground SubName
    TemplateToolkit TextUnidecode TieCacheLRU TieCacheLRUExpires
    TieRegexpHash TimeDate URI URIFind UUIDTiny
    XMLParser XMLSimple YAMLLibYAML
  ]);

  prePatch = ''
    mkdir CPAN_used
    # slimserver doesn't work with current DBIx/SQL versions, use bundled copies
    mv CPAN/DBIx CPAN/SQL CPAN_used
    rm -rf CPAN
    rm -rf Bin
    touch Makefile.PL
  '';

  buildPhase = "
    mv lib tmp
    mkdir -p lib/perl5/site_perl
    mv CPAN_used/* lib/perl5/site_perl
    cp -rf tmp/* lib/perl5/site_perl
  ";

  doCheck = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  outputs = [ "out" ];

  meta = with stdenv.lib; {
    description = "Server for Logitech Squeezebox players. This server is also called Logitech Media Server";
    homepage = https://github.com/Logitech/slimserver;
    # the firmware is not under a free license!
    # https://github.com/Logitech/slimserver/blob/public/7.9/License.txt
    license = licenses.unfree;
    maintainers = with maintainers; [ phile314 ];
    platforms = platforms.linux;
  };
}
