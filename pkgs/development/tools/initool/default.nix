{ stdenv
, mlton
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "initool";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "initool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-f426yzSYcrhd0MOZc5vDg4T4m/RdWzTz/KPzb65h03U=";
  };

  nativeBuildInputs = [ mlton ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin initool

    runHook postInstall
  '';

  meta = with lib; {
    inherit (mlton.meta) platforms;

    description = "Manipulate INI files from the command line";
    mainProgram = "initool";
    homepage = "https://github.com/dbohdan/initool";
    license = licenses.mit;
    maintainers = with maintainers; [ e1mo ];
    changelog = "https://github.com/dbohdan/initool/releases/tag/v${finalAttrs.version}";
  };
})
