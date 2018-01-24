{ stdenv, lib, fetchFromGitHub, cmake, git
, lmdb, nlohmann_json
, qtbase, qtmultimedia, qttranslations, qttools }:

let
  # The dependencies here are quite ugly - hopefully nheko cleans things up in
  # future versions
  lmdbxx = fetchFromGitHub {
    owner  = "bendiken";
    repo   = "lmdbxx";
    rev    = "0b43ca87d8cfabba392dfe884eb1edb83874de02";
    sha256 = "1whsc5cybf9rmgyaj6qjji03fv5jbgcgygp956s3835b9f9cjg1n";
  };

  tweeny = stdenv.mkDerivation {
    name = "tweeny";

    src = fetchFromGitHub {
      owner  = "mobius3";
      repo   = "tweeny";
      rev    = "b94ce07cfb02a0eb8ac8aaf66137dabdaea857cf";
      sha256 = "1wyyq0j7dhjd6qgvnh3knr70li47hmf5394yznkv9b1indqjx4mi";
    };

    nativeBuildInputs = [ cmake ];
  };

  variant = stdenv.mkDerivation rec {
    name = "variant-${version}";
    version = "1.3.0";

    src = fetchFromGitHub {
      owner  = "mpark";
      repo   = "variant";
      rev    = "v${version}";
      sha256 = "1naz3gvc3pbflv7nn7imcysd7ilir9v86324ab6lsyrxlhsr9ym4";
    };

    nativeBuildInputs = [ cmake ];
  };

  structs = stdenv.mkDerivation rec {
    name = "nheko-matrix-structs";

    src = fetchFromGitHub {
      owner  = "mujx";
      repo   = "matrix-structs";
      rev    = "91bb2b85a75d664007ef81aeb500d35268425922";
      sha256 = "1v544pv18sd91gdrhbk0nm54fggprsvwwrkjmxa59jrvhwdk7rsx";
    };

    patches = [ ./structs-no-download.patch ];

    postPatch = ''
      cp ${nlohmann_json}/include/nlohmann/json.hpp include/
      cp ${variant}/include/mpark/{config,in_place,lib,variant}.hpp include/
    '';

    buildInputs = [ nlohmann_json variant ];

    nativeBuildInputs = [ cmake ];
  };

in stdenv.mkDerivation rec {
  name = "nheko-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner  = "mujx";
    repo   = "nheko";
    rev    = "v${version}";
    sha256 = "178z64vkl7nmr1amgsgvdcwipj8czp7vbvidxllxiwal21yvqpky";
  };

  buildInputs = [
    lmdb structs tweeny
    qtbase qtmultimedia qttranslations
  ];

  nativeBuildInputs = [ cmake qttools ];

  cmakeFlags = [
    "-DLMDBXX_INCLUDE_DIR=${lmdbxx}"
    "-DMATRIX_STRUCTS_ROOT=${structs}"
    "-DMATRIX_STRUCTS_INCLUDE_DIR=${structs}/include/matrix_structs"
    "-DTWEENY_INCLUDE_DIR=${tweeny}/include/tweeny"
  ];

  meta = with lib; {
    description = "Desktop client for the Matrix protocol";
    homepage    = https://matrix.org/docs/projects/client/nheko.html;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (qtbase.meta) platforms;
  };
}
