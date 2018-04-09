{ stdenv, buildPythonPackage, fetchPypi, isPy3k
, pkgconfig
, udev, libyaml, openzwave, cython
, six, pydispatcher, urwid }:

buildPythonPackage rec {
  pname = "python_openzwave";
  version = "0.4.4";

  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "17wdgwg212agj1gxb2kih4cvhjb5bprir4x446s8qwx0mz03azk2";
    extension = "zip";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ udev libyaml openzwave cython six pydispatcher urwid ];

  postPatch = ''
    # Patch in default path to config
    sed -i 's#"/etc/openzwave/"#"${openzwave}/etc/openzwave"#' src-lib/libopenzwave/libopenzwave.pyx
  '';

  preConfigure = ''
    PKG_CONFIG_PATH+=":${openzwave}/usr/lib/pkgconfig"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/OpenZWave/python-openzwave;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.etu ];
    description = "Python-openzwave is a python wrapper for the openzwave c++ library.";
  };
}
