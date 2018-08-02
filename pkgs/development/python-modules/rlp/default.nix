{ lib, fetchPypi, buildPythonPackage, pypandoc, pytest }:

let
  setuptools-markdown = buildPythonPackage rec {
    pname = "setuptools-markdown";
    version = "0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0xzx2krdn2g1kw949mvxkxkc1gflpqmrj9lxdnvdpds3wds66nh6";
    };
    propagatedBuildInputs = [ pypandoc ];
  };

  eth-utils = buildPythonPackage rec {
    pname = "eth-utils";
    version = "1.0.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "1d79narwn4wgcyz4k8c306xfhwllz2rhd3591g4f9rx7zpd1pdqf";
    };
    propagatedBuildInputs = [ setuptools-markdown ];
  };

in buildPythonPackage rec {
  pname = "rlp";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "492c11b18e89af42f98e96bca7671ffee4ad4cf5e69ea23b4d2221157d81b512";
  };

  checkInputs = [ pytest ];
  propagatedBuildInputs = [ setuptools-markdown eth-utils ];

  meta = {
    description = "A package for encoding and decoding data in and from Recursive Length Prefix notation";
    homepage = "https://github.com/ethereum/pyrlp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gebner ];
  };
}
