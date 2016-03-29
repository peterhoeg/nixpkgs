{ stdenv, fetchFromGitHub, coreutils, python27Packages }:

let
  packageCollection = python27Packages;

in stdenv.mkDerivation rec {
  version = "2.4.3";
  name = "Shinken-${version}";

  # Python 3 is not supported
  disabled = packageCollection.isPy3k;

  src = fetchFromGitHub {
    owner  = "naparuba";
    repo   = "shinken";
    rev    = version;
    sha256 = "09z72vqrsqbn3rbj85ic5izm7qchkkjw2hqyjridqxy0rn7jkla4";
  };

  # no binaries to strip
  dontStrip = true;
  doCheck = false;

  # missing: logging tagging
  buildInputs = with packageCollection; [ coreutils unittest2 wrapPython ];
  propagatedBuildInputs = with packageCollection; [ python ] ++ pythonPath;

  pythonPath = with packageCollection; [
    arrow bottle cffi cherrypy django paramiko pycurl pymongo pyopenssl readline
  ];

  installPhase = ''
    mkdir -p $out/share/doc/shinken/sysvinit $out/etc/systemd/system

    export PYTHONPATH=$out/${packageCollection.python.sitePackages}:$PYTHONPATH

    python setup.py install --root=$out --prefix=.

    cp for_fedora/systemd/* $out/etc/systemd/system

    mv $out/etc/shinken                     $out/share/doc/shinken/examples
    mv $out/etc/{default,init.d}            $out/share/doc/shinken/sysvinit
    mv $out/usr/bin                         $out/bin
    #mv $out/var/lib/shinken/doc/build/html  $out/share/doc/shinken/manual
    mv $out/var/lib/shinken/libexec         $out/libexec
    mv $out/var/lib/shinken/cli             $out/libexec/cli

    rm -rf $out/{bin/shinken,etc,usr,var}

    # the spelling is just awful...
    find $out -type f -print0 | xargs -0 sed -i \
      -e 's/onnexion/onnection/g' \
      -e 's/ptionnal/ptional/g'

    # patch up examples so they work
    sed -i $out/share/doc/shinken/examples/*.cfg \
      -e "s|/var/lib/shinken|$out/share/doc/shinken/examples|g" \
      -e "s|/var/run|/run|g" \

    # permissions
    find $out/libexec -name '*.py' | xargs chmod 755

    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  checkPhase = ''
    patchShebangs test
    cd test
    bash ./quick_tests.sh
  '';

  meta = with stdenv.lib; {
    homepage = http://www.shinken-monitoring.org/;
    description = "A monitoring framework compatible with Nagios configuration and plugins";
    license = licenses.agpl3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
