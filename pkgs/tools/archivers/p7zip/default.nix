{ stdenv, fetchFromGitHub, fetchpatch, lib, cmake, wxGTK31-gtk3, enableUnfree ? false, enableGUI ? true }:

stdenv.mkDerivation rec {
  pname = "p7zip";
  version = "17.03";

  src = fetchFromGitHub {
    owner = "jinfeihan57";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bYxoxeFdJMYQzEZ0Yc1hgViIYHgxNo/vkmDc8kFS930=";
  };

  sourceRoot = "source/CPP/7zip/CMAKE";

  postPatch = ''
    # we get a ton of warnings otherwise
    find . -name CMakeLists.txt -print0 | xargs -0 sed -i 's/^cmake_minimum_required.*/cmake_minimum_required(VERSION ${cmake.version})/'
  '' + lib.optionalString (!enableUnfree) ''
    # Remove non-free RAR source code
    # (see DOC/License.txt, https://fedoraproject.org/wiki/Licensing:Unrar)
    rm -r Rar
    sed -i '/Rar/d' CMakeLists.txt
  '' + lib.optionalString stdenv.isDarwin ''
    cp makefile.macosx_llvm_64bits makefile.machine
  '';

  buildInputs = lib.optional enableGUI wxGTK31-gtk3;

  nativeBuildInputs = [ cmake ];

  setupHook = ./setup-hook.sh;

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=c++11-narrowing";

  # for reasons unknown, the Makefile with the install info is written to bin with the binary artifacts
  preInstall = ''
    cd bin
  '';

  meta = with lib; {
    description = "A new p7zip fork with additional codecs and improvements (forked from https://sourceforge.net/projects/p7zip/)";
    homepage = "https://github.com/jinfeihan57/p7zip";
    # RAR code is under non-free UnRAR license, but we remove it
    license = if enableUnfree then licenses.unfree else licenses.lgpl2Plus;
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.unix;
  };
}
