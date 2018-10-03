{ stdenv, lib, fetchFromGitLab }:

stdenv.mkDerivation rec {
  name = "sddm-ocr-theme-${version}";
  version = "0.0.1.20180927";

  src = fetchFromGitLab {
    owner  = "peterhoeg";
    repo   = "sddm-high-contrast";
    rev    = "fe25b1775e42f76d9dac848429e2d2ecd863f9bb";
    sha256 = "15yrcihxmfgikhsrls683wylnp8lmfyq26zs764gyf8glbl0zkaj";
  };

  postPatch = ''
    rm -rf bin
    substituteInPlace Main.qml \
      --replace 'QtQuick 2'         'QtQuick ''${COMPONENT_VERSION} \
      --replace 'SddmComponents 2' 'SddmComponents ''${COMPONENT_VERSION}
  '';

  buildCommand = ''
    dir=$out/share/sddm/themes/nixos-ocr

    mkdir -p $dir
    cp -r ${src}/* $dir
  '';

  meta = with lib; {
    description = "OCR friendly high-constrast theme for SDDM";
    homepage    = src.meta.homepage;
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
