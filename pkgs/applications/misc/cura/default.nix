{ mkDerivation, lib, fetchFromGitHub, cmake, python3, qtbase, qtquickcontrols2, curaengine }:

let
  inherit (curaengine) version;

  materials = fetchFromGitHub {
    owner = "Ultimaker";
    repo = "fdm_materials";
    rev = version;
    sha256 = "0g2dkph0ll7d9109n17vmfwb4fpc8lhyb1z1q68j8vblyvg08d12";
  };

  libsavitar = python3.pkgs.buildPythonPackage {
    pname = "libsavitar";
    inherit version;
    format = "other";

    src = fetchFromGitHub {
      owner = "Ultimaker";
      repo = "libsavitar";
      rev = version;
      sha256 = "1bz8ga0n9aw65hqzajbr93dcv5g555iaihbhs1jq2k47cx66klzv";
    };

    propagatedBuildInputs = with python3.pkgs; [ sip ];

    nativeBuildInputs = [ cmake ];

    postPatch = ''
      # To workaround buggy SIP detection which overrides PYTHONPATH
      sed -i '/SET(ENV{PYTHONPATH}/d' cmake/FindSIP.cmake
    '';
  };

in mkDerivation rec {
  name = "cura-${version}";

  src = fetchFromGitHub {
    owner = "Ultimaker";
    repo = "Cura";
    rev = version;
    sha256 = "0wzkbqdd1670smw1vnq634rkpcjwnhwcvimhvjq904gy2fylgr90";
  };

  buildInputs = [ qtbase qtquickcontrols2 ];
  propagatedBuildInputs = with python3.pkgs; [ libsavitar numpy-stl pyserial requests shapely uranium zeroconf ];
  nativeBuildInputs = [ cmake python3.pkgs.wrapPython ];

  cmakeFlags = [
    "-DURANIUM_DIR=${python3.pkgs.uranium.src}"
    "-DCURA_VERSION=${version}"
  ];

  postPatch = ''
    sed -i 's,/python''${PYTHON_VERSION_MAJOR}/dist-packages,/python''${PYTHON_VERSION_MAJOR}.''${PYTHON_VERSION_MINOR}/site-packages,g' CMakeLists.txt
    sed -i 's, executable_name = .*, executable_name = "${curaengine}/bin/CuraEngine",' plugins/CuraEngineBackend/CuraEngineBackend.py
  '';

  postInstall = ''
    mkdir -p $out/share/cura/resources/materials
    cp ${materials}/*.fdm_material $out/share/cura/resources/materials/
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    description = "3D printer / slicing GUI built on top of the Uranium framework";
    homepage = https://github.com/Ultimaker/Cura;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
