{ gcc6Stdenv, lib, fetchFromGitHub, fetchurl, scons, pkgconfig
, libpng, SDL, SDL_mixer, libGL, libGLU, physfs
}:

# no dxx release will compile with gcc7 without patches and gcc8 at all so just
# stick to gcc6 for now

gcc6Stdenv.mkDerivation rec {
  pname = "dxx-rebirth";
  version = "0.60.0-beta2";

  src = fetchFromGitHub {
    owner = "dxx-rebirth";
    repo = "dxx-rebirth";
    rev = version;
    sha256 = "01mv4yjcydmi04p51zbiv0786853h6hm8ryaz9zsvpd90rfdmz66";
  };

  nativeBuildInputs = [ pkgconfig scons ];

  buildInputs = [ libpng libGL libGLU physfs SDL SDL_mixer ];

  sconsFlags = [
    "lto=1"
    "sdlmixer=1"
    "sharepath=${placeholder "out"}/share/${pname}"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    install -Dm644 -t $out/share/doc/${pname} *.txt
  '';

  meta = with lib; {
    description = "Source Port of the Descent 1 and 2 engines";
    homepage = "https://www.dxx-rebirth.com/";
    license = licenses.free;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = with platforms; linux;
  };
}
