{ stdenv
, lib
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, qttools
, darwin ? null
, libsecret
, pcre
}:

assert stdenv.isDarwin -> darwin != null;

mkDerivation rec {
  pname = "qtkeychain";
  version = "0.12.0"; # verify after nix-build with `grep -R "set(PACKAGE_VERSION " result/`

  src = fetchFromGitHub {
    owner = "frankosterfeld";
    repo = "qtkeychain";
    rev = "v${version}";
    sha256 = "sha256-2c0wtjcWtVRSyYJN4HcSIpUoYh8uskC44zswtki3IT4=";
  };

  patches = lib.optional stdenv.isDarwin [ ./0002-Fix-install-name-Darwin.patch ];

  cmakeFlags = [ "-DQT_TRANSLATIONS_DIR=share/qt/translations" ];

  nativeBuildInputs = [ cmake pkg-config qttools ];

  buildInputs = [
    libsecret
    pcre
  ]
  ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    Security
  ]);

  meta = with lib; {
    description = "Platform-independent Qt API for storing passwords securely";
    homepage = "https://github.com/frankosterfeld/qtkeychain";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
