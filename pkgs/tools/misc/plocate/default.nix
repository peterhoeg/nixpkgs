{ stdenv
, lib
, fetchgit
, pkg-config
, meson
, ninja
, systemd
, liburing
, zstd
}:

stdenv.mkDerivation rec {
  pname = "plocate";
  version = "1.1.13";

  src = fetchgit {
    url = "https://git.sesse.net/plocate";
    rev = version;
    sha256 = "sha256-Vz8lOE810g6l8izmw6oOVhJyUlabKsfaIDyLtm4jKbY=";
  };

  postPatch = ''
    sed -i meson.build -e '/mkdir\.sh/d'
  '';

  nativeBuildInputs = [ meson ninja pkg-config ];

  buildInputs = [ systemd liburing zstd ];

  mesonFlags = [
    "-Dsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "-Dsharedstatedir=/var/lib"
  ];

  meta = with lib; {
    description = "Much faster locate";
    homepage = "https://plocate.sesse.net/";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.linux;
  };
}
