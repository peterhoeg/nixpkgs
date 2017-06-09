{ lib
, fetchurl
, fetchpatch
, buildPythonPackage
, pycrypto
, paramiko
, jinja2
, pyyaml
, httplib2
, boto
, six
, netaddr
, dns
, windowsSupport ? false
, pywinrm ? null
}:

buildPythonPackage rec {
  pname = "ansible";
  version = "2.3.1.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "http://releases.ansible.com/ansible/${name}.tar.gz";
    sha256 = "1xdr82fy8gahxh3586wm5k1bxksys7yl1f2n24shrk8gf99qyjyd";
  };

  patches = [
    (fetchpatch {
      name = "include_role.patch";
      url = "https://patch-diff.githubusercontent.com/raw/ansible/ansible/pull/23104.patch";
      sha256 = "1fac43mqdik35jp1bywln494xahvf3805zxx134qmjrm416qhc5v";
    })
  ];

  prePatch = ''
    sed -i "s,/usr/,$out," lib/ansible/constants.py
  '';

  doCheck = false;
  dontStrip = true;
  dontPatchELF = true;
  dontPatchShebangs = false;

  propagatedBuildInputs = [ pycrypto paramiko jinja2 pyyaml httplib2
    boto six netaddr dns ] ++ lib.optional windowsSupport pywinrm;

  meta = {
    homepage = "http://www.ansible.com";
    description = "A simple automation tool";
    license = with lib.licenses; [ gpl3] ;
    maintainers = with lib.maintainers; [
      jgeerds
      joamaki
    ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
