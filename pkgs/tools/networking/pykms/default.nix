{ lib, runtimeShell, fetchFromGitHub, python3Packages, writeText, writeScript
, coreutils, sqlite }:

let
  pypkgs = python3Packages;

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

  dbScript = writeScript "create_pykms_db.sh" (with lib; ''
    #!${runtimeShell}

    set -eEuo pipefail

    db=$1

    if [ ! -e $db ] ; then
      ${getBin sqlite}/bin/sqlite3 $db < ${dbSql}
    fi
  '');

in pypkgs.buildPythonApplication rec {
  pname = "pykms";
  version = "20190611";

  src = fetchFromGitHub {
    owner  = "SystemRage";
    repo   = "py-kms";
    rev    = "dead208b1593655377fe8bc0d74cc4bead617103";
    sha256 = "065qpkfqrahsam1rb43vnasmzrangan5z1pr3p6s0sqjz5l2jydp";
  };

  postPatch = ''
    substituteInPlace pykms_DB2Dict.py \
      --replace "'KmsDataBase.xml'" "'$out/share/${pname}/KmsDataBase.xml'"

    # we are logging to journal
    sed -i pykms_Misc.py \
      -e '6ifrom systemd import journal' \
      -e 's/log_obj.addHandler(log_handler)/log_obj.addHandler(journal.JournalHandler())/'
  '';

  sourceRoot = "source/py-kms";

  propagatedBuildInputs = with pypkgs; [ systemd pytz tzlocal ];

  siteDir = placeholder "out" + "/" + pypkgs.python.sitePackages;

  format = "other";

  # there are no tests
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm444 -t ${siteDir} *.py
    install -Dm444 -t $out/share/${pname} *.xml

    for b in Client Server ; do
      makeWrapper ${pypkgs.python.interpreter} $out/bin/''${b,,} \
        --argv0 ''${b,,} \
        --add-flags ${siteDir}/pykms_$b.py \
        --prefix PYTHONPATH : ${lib.concatMapStringsSep ":" (e:
          "$(toPythonPath ${e})") propagatedBuildInputs}
    done

    install -Dm555 ${dbScript} $out/libexec/create_pykms_db.sh

    install -Dm444 ../README.md -t $out/share/doc/${pname}

    ${pypkgs.python.interpreter} -m compileall ${siteDir}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Windows KMS (Key Management Service) server written in Python";
    homepage    = "https://github.com/SystemRage/py-kms";
    license     = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
