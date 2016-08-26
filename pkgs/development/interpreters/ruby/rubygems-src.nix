{ fetchurl
, version ? "2.6.1"
, sha256 ? "0kqzmrd91h19q5y84wyx53rx0x09hdffp84gasy0a73s6sld3i69"
}:
fetchurl {
  url = "http://production.cf.rubygems.org/rubygems/rubygems-${version}.tgz";
  sha256 = sha256;
}
