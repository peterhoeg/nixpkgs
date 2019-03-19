{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig
, jsoncpp, systemd }:

stdenv.mkDerivation rec {
  name = "oomd-unstable-${version}";
  version = "ef3106ab8c68d1525758a9b88c4db7aaccaf3a0e";

  src = fetchFromGitHub rec {
    owner = "facebookincubator";
    repo = "oomd";
    rev = version;
    sha256 = "1xyj93m816qd5d3kavxavdaf3abn67fx67jm42pnq6lb27v14a6h";
  };

  buildInputs = [ jsoncpp systemd ];

  nativeBuildInputs = [ meson ninja pkgconfig ];

  meta = with stdenv.lib; {
    description = "A userspace out-of-memory killer";
    homepage = https://github.com/facebookincubator/oomd;
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
