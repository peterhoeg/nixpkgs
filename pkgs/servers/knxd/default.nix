{ stdenv, fetchFromGitHub, autoreconfHook, perl, pkgconfig
, fmt, libev, libusb, systemd }:

stdenv.mkDerivation rec {
  name = "knxd-${version}";
  version = "0.14.25";

  src = fetchFromGitHub {
    owner = "knxd";
    repo = "knxd";
    rev = "v${version}";
    sha256 = "1cawzswms0kk52l2bhkrzrmk6bki7g4zz9yajly8gddin8mkcavg";
  };

  postPatch = ''
    for f in src/client/{cs,java,php}/Makefile.am ; do
      substituteInPlace $f --replace /bin/true true
    done

    export SYSTEMD_DIR=$out/lib/systemd/system
    export SYSTEMD_MODULES_LOAD=$out/lib/modules-load.d
    export SYSTEMD_SYSUSERS_DIR=$out/lib/sysusers.d
  '';

  buildInputs = [ fmt libev libusb systemd ];

  nativeBuildInputs = [ autoreconfHook perl pkgconfig ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://home-assistant.io/;
    description = "Open-source home automation platform running on Python 3";
    license = licenses.asl20;
    maintainers = with maintainers; [ f-breidenstein dotlambda ];
  };
}
