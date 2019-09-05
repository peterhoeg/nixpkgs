{ aspell
, bc
, boost168 # 2.3.3 bundles 1.6.8
, cmake
, enchant
, fetchpatch
, fetchurl
, file
, hunspell
, lib
, makeWrapper
, mkDerivation
, mythes
, ninja
, pkgconfig
, python
, qtbase
, qtsvg
}:

let
  # we have to manually provide the paths, so define them which allows us to
  # check if they are actually present before continuing with the build
  enchantInc = "${enchant.dev}/include/enchant-2";
  enchantLib = "${enchant}/lib/libenchant-2.so";
  hunspellLib = "${hunspell.out}/lib/libhunspell-1.7.so";

in
mkDerivation rec {
  pname = "lyx";
  version = "2.3.3";

  src = fetchurl {
    url = "ftp://ftp.lyx.org/pub/lyx/stable/2.3.x/${pname}-${version}.tar.xz";
    sha256 = "0faf5028pdp42k6m9xd97ymim5xx370qlgv9lxvd50djvpmyy7lr";
  };

  nativeBuildInputs = [ cmake makeWrapper ninja pkgconfig ];

  buildInputs = [
    aspell
    bc
    boost168
    enchant
    file # for libmagic
    hunspell
    mythes
    python
    qtbase
    qtsvg
  ];

  cmakeFlags = [
    # we need to manually provide these in order for them to be found
    "-DENCHANT_INCLUDE_DIR=${enchantInc}"
    "-DENCHANT_LIBRARY=${enchantLib}"
    "-DHUNSPELL_LIBRARY=${hunspellLib}"
    "-DLYX_ENCHANT=ON"
    # we prefer to use our system-installed libraries
    "-DLYX_EXTERNAL_BOOST=ON"
    "-DLYX_EXTERNAL_MYTHES=ON"
    "-DLYX_INSTALL=ON"
    "-DLYX_MERGE_FILES=OFF" # supposedly speeds up compilation but breaks the build
    "-DLYX_PACKAGE_SUFFIX=OFF"
    "-DLYX_PROGRAM_SUFFIX=OFF"
    "-DLYX_RELEASE=ON" # lyx defaults to debug mode
  ];

  # Sanity check up front that our manually provided paths actually exist
  preBuild = ''
    checkDep() {
      if [ ! -e $1 ]; then
        echo "Unable to find: $1"
        exit 1
      fi
    }

    ${lib.concatMapStringsSep "\n" (l:
      "checkDep ${l}"
    ) [ enchantInc enchantLib hunspellLib ]}
  '';

  # half the tests are broken
  doCheck = false;

  qtWrapperArgs = [
    # python is used during runtime to do various tasks
    "--prefix PATH : ${lib.makeBinPath [ python ]}"
  ];

  meta = with lib; {
    description = "WYSIWYM frontend for LaTeX, DocBook";
    homepage = "https://www.lyx.org";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ vcunat ];
    platforms = platforms.linux;
  };
}
