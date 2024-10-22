{
  lib,
  fetchFromGitHub,
  python3,
  writeText,
  writeShellScript,
  sqlite,
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
  version = "0-unstable-2024-05-28";

  src = fetchFromGitHub {
    owner = "Py-KMS-Organization";
    repo = "py-kms";
    rev = "646f4766f4195dbea0695700a7ddaac70a3294f9";
    hash = "sha256-YCqPo7WkCfXyuTjL4IYapdcUN/Vj465Jz6XhQessyz0=";
  };

  sourceRoot = "${src.name}/py-kms";

  propagatedBuildInputs = with pypkgs; [
    systemd
    pytz
    tzlocal
    dnspython
  ];

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

    PYTHONPATH="$PYTHONPATH:$siteDir"

    mv * $siteDir
    for b in Client Server ; do
      makeWrapper ${python3.interpreter} $out/bin/''${b,,} \
        --argv0 pykms-''${b,,} \
        --add-flags $siteDir/pykms_$b.py \
        --set PYTHONPATH $PYTHONPATH
    done

    install -Dm755 ${dbScript} $out/libexec/create_pykms_db.sh

    install -Dm644 ../README.md -t $out/share/doc/pykms

    ${python3.interpreter} -m compileall $siteDir

    runHook postInstall
  '';

  meta = with lib; {
    description = "Windows KMS (Key Management Service) server written in Python";
    homepage = "https://github.com/Py-KMS-Organization/py-kms";
    license = licenses.unlicense;
    maintainers = with maintainers; [
      peterhoeg
      zopieux
    ];
  };
}
