{
  lib,
  stdenv,
  fetchFromGitHub,
  hiredis,
  http-parser,
  jansson,
  libevent,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webdis";
  version = "0.1.23";

  src = fetchFromGitHub {
    owner = "nicolasff";
    repo = "webdis";
    rev = finalAttrs.version;
    hash = "sha256-eFUI3RDDrEI1bV+SfTVsIO6yjswK7tzgNsNepoo7DQ4=";
  };

  buildInputs = [
    hiredis
    http-parser
    jansson
    libevent
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "CONFDIR=${placeholder "out"}/share/webdis"
  ];

  meta = {
    description = "Redis HTTP interface with JSON output";
    mainProgram = "webdis";
    homepage = "https://webd.is/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.unix;
  };
})
