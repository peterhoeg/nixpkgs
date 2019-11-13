{ stdenv, lib, fetchurl, cabextract }:

let
  fonts = [
    { name = "andale";  sha256 = "0w7927hlwayqf3vvanf8f3qp2g1i404jzqvhp1z3mp0sjm1gw905"; displayName = "Andale-Mono"; }
    { name = "arial";   sha256 = "1xkqyivbyb3z9dcalzidf8m4npzfpls2g0kldyn8g73f2i6plac5"; displayName = "Arial"; }
    { name = "arialb";  sha256 = "1a60zqrg63kjnykh5hz7dbpzvx7lyivn3vbrp7jyv9d1nvzz09d4"; displayName = "Arial-Black"; }
    { name = "comic";   sha256 = "0ki0rljjc1pxkbsxg515fwx15yc95bdyaksa3pjd89nyxzzg6vcw"; displayName = "Comic-Sans-MS"; }
    { name = "courie";  sha256 = "111k3waxki9yyxpjwl2qrdkswvsd2dmvhbjmmrwyipam2s31sldv"; displayName = "Courier-New"; }
    { name = "georgi";  sha256 = "0083jcpd837j2c06kp1q8glfjn9k7z6vg3wi137savk0lv6psb1c"; displayName = "Georgia"; }
    { name = "impact";  sha256 = "1yyc5z7zmm3s418hmrkmc8znc55afsrz5dgxblpn9n81fhxyyqb0"; displayName = "Impact"; }
    { name = "times";   sha256 = "1aq7z3l46vwgqljvq9zfgkii6aivy00z1529qbjkspggqrg5jmnv"; displayName = "Times-New-Roman"; }
    { name = "trebuc";  sha256 = "1jfsgz80pvyqvpfpaiz5pd8zwlcn67rg2jgynjwf22sip2dhssas"; displayName = "Trebuchet"; }
    { name = "verdan";  sha256 = "15mdbbfqbyp25a6ynik3rck3m3mg44plwrj79rwncc9nbqjn3jy1"; displayName = "Verdana"; }
    { name = "wd97vwr"; sha256 = "1lmkh3zb6xv47k0z2mcwk3vk8jff9m845c9igxm14bbvs6k2c4gn"; displayName = "Tahoma"; }
    { name = "webdin";  sha256 = "0nnp2znmnmx87ijq9zma0vl0hd46npx38p0cc6lgp00hpid5nnb4"; displayName = "Webdings"; }
  ];

  exes = map ({ name, sha256, ... }: fetchurl {
    url = "mirror://sourceforge/corefonts/${name}32.exe";
    inherit sha256;
  }) fonts;

  eula = fetchurl {
    url = "http://corefonts.sourceforge.net/eula.htm";
    sha256 = "1aqbcnl032g2hd7iy56cs022g47scb0jxxp3mm206x1yqc90vs1c";
  };

in
stdenv.mkDerivation rec {
  pname = "corefonts";
  version = "2006-05-07";

  nativeBuildInputs = [ cabextract ];

  buildCommand = ''
    ${stdenv.lib.concatMapStringsSep "\n" (e: ''
      cabextract --lowercase ${e}
    '') exes}

    # From wd97vwr.exe
    cabextract --lowercase viewer1.cab

    install -Dm444 -t $out/share/fonts/truetype *.ttf

    # Also put the EULA there to be on the safe side.
    install -Dm444 ${eula} $out/share/doc/${pname}/${eula.name}

    # Set up no-op font configs to override any aliases set up by
    # other packages.
    mkdir -p $out/etc/fonts/conf.d
    ${lib.concatMapStringsSep "\n" (e: ''
      substitute ${./no-op.conf} \
        $out/etc/fonts/conf.d/30-${lib.toLower e.displayName}.conf \
        --subst-var-by fontname "${e.displayName}"
    '') fonts}
  '';

  meta = with lib; {
    description = "Microsoft's TrueType core fonts for the Web";
    homepage = "http://corefonts.sourceforge.net/";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.all;
    # Set a non-zero priority to allow easy overriding of the
    # fontconfig configuration files.
    priority = 5;
  };
}
