{ fetchurl }:

rec {
  fetchSrc = { name, sha256 }: fetchurl {
    url = "https://download.documentfoundation.org/libreoffice/src/${subdir}/libreoffice-${name}-${version}.tar.xz";
    inherit sha256;
  };

  major = "7";
  minor = "5";
  patch = "1";
  tweak = "2";

  subdir = "${major}.${minor}.${patch}";

  version = "${subdir}${if tweak == "" then "" else "."}${tweak}";

  src = fetchurl {
    url = "https://download.documentfoundation.org/libreoffice/src/${subdir}/libreoffice-${version}.tar.xz";
    hash = "sha256-kg3dFbyEz2CjPPDGi7Zqje140VBGPBXrqifPt/OmwLc=";
  };

  # FIXME rename
  translations = fetchSrc {
    name = "translations";
    sha256 = "sha256-o/yee2qLPLyFPVvFLKysdzc37DOi+0wKYuCPrxspuRo=";
  };

  # the "dictionaries" archive is not used for LO build because we already build hunspellDicts packages from
  # it and LibreOffice can use these by pointing DICPATH environment variable at the hunspell directory

  help = fetchSrc {
    name = "help";
    sha256 = "sha256-6aiS/LdhY3nv3ockNmqEUPcVfOA7iJPjhUJdbzT3qLM=";
  };
}
