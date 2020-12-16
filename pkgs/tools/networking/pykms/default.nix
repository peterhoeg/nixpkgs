{ lib
, fetchFromGitHub
, python3
, writeText
, writeShellScript
, sqlite
}:
let
  pypkgs = python3.pkgs;

  dbSql = writeText "create_pykms_db.sql" ''
    CREATE TABLE clients(
      clientMachineId TEXT,
      machineName     TEXT,
      applicationId   TEXT,
      skuId           TEXT,
      licenseStatus   TEXT,
      lastRequestTime INTEGER,
      kmsEpid         TEXT,
      requestCount    INTEGER
    );
  '';

  dbScript = writeShellScript "create_pykms_db.sh" ''
    set -eEuo pipefail

    db=''${1:-/var/lib/pykms/clients.db}

    if [ ! -e $db ] ; then
      ${lib.getBin sqlite}/bin/sqlite3 $db < ${dbSql}
    fi
  '';

in
pypkgs.buildPythonApplication rec {
  pname = "pykms";
  version = "unstable-2020-12-13";

  src = fetchFromGitHub {
    owner = "SystemRage";
    repo = "py-kms";
    rev = "ceb5d0d07688ed2869f329565c5757704512c333";
    sha256 = "sha256-ItwJjp7hFu0FmoaGRpWQsYYX/Z43aPjzQ8g0ZEx1aOg=";
  };

  sourceRoot = "source/py-kms";

  propagatedBuildInputs = with pypkgs; [ systemd pytz tzlocal ];

  postPatch = ''
    siteDir=$out/${python3.sitePackages}

    substituteInPlace pykms_DB2Dict.py \
      --replace "'KmsDataBase.xml'" "'$siteDir/KmsDataBase.xml'"
  '';

  format = "other";

  # there are no tests
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $siteDir

    mv * $siteDir
    for b in Client Server ; do
      makeWrapper ${python3.interpreter} $out/bin/''${b,,} \
        --argv0 pykms-''${b,,} \
        --add-flags $siteDir/pykms_$b.py
    done

    install -Dm755 ${dbScript} $out/libexec/create_pykms_db.sh

    install -Dm644 ../README.md -t $out/share/doc/pykms

    ${python3.interpreter} -m compileall $siteDir

    runHook postInstall
  '';

  meta = with lib; {
    description = "Windows KMS (Key Management Service) server written in Python";
    homepage = "https://github.com/SystemRage/py-kms";
    license = licenses.unlicense;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
