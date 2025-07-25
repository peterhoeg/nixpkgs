{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch,
  pythonOlder,
  replaceVars,

  # build-system
  setuptools,

  # patched in
  geos,
  gdal,
  withGdal ? false,

  # dependencies
  asgiref,
  sqlparse,

  # optional-dependencies
  argon2-cffi,
  bcrypt,

  # tests
  aiosmtpd,
  docutils,
  geoip2,
  jinja2,
  numpy,
  pillow,
  pylibmc,
  pymemcache,
  python,
  pyyaml,
  pytz,
  redis,
  selenium,
  tblib,
  tzdata,
}:

buildPythonPackage rec {
  pname = "django";
  version = "5.2.4";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "django";
    repo = "django";
    rev = "refs/tags/${version}";
    hash = "sha256-0AtH3vyEeQUKep17j5koiUi/ACgLc9JLMxkwWovCkvE=";
  };

  patches = [
    (replaceVars ./django_5_set_zoneinfo_dir.patch {
      zoneinfo = tzdata + "/share/zoneinfo";
    })
    # prevent tests from messing with our pythonpath
    ./django_5_tests_pythonpath.patch
    # disable test that expects timezone issues
    ./django_5_disable_failing_tests.patch
  ]
  ++ lib.optionals withGdal [
    (replaceVars ./django_5_set_geos_gdal_lib.patch {
      geos = geos;
      gdal = gdal;
      extension = stdenv.hostPlatform.extensions.sharedLibrary;
    })
  ];

  postPatch = ''
    substituteInPlace tests/utils_tests/test_autoreload.py \
      --replace-fail "/usr/bin/python" "${python.interpreter}"
  '';

  build-system = [ setuptools ];

  dependencies = [
    asgiref
    sqlparse
  ];

  optional-dependencies = {
    argon2 = [ argon2-cffi ];
    bcrypt = [ bcrypt ];
  };

  nativeCheckInputs = [
    # tests/requirements/py3.txt
    aiosmtpd
    docutils
    geoip2
    jinja2
    numpy
    pillow
    pylibmc
    pymemcache
    pyyaml
    pytz
    redis
    selenium
    tblib
    tzdata
  ]
  ++ lib.flatten (lib.attrValues optional-dependencies);

  preCheck = ''
    # make sure the installed library gets imported
    rm -rf django

    # fails to import github_links from docs/_ext/github_links.py
    rm tests/sphinx/test_github_links.py

    # provide timezone data, works only on linux
    export TZDIR=${tzdata}/${python.sitePackages}/tzdata/zoneinfo

    export PYTHONPATH=$PWD/docs/_ext:$PYTHONPATH
  '';

  checkPhase = ''
    runHook preCheck

    pushd tests
    # without --parallel=1, tests fail with an "unexpected error due to a database lock" on Darwin
    ${python.interpreter} runtests.py --settings=test_sqlite ${lib.optionalString stdenv.hostPlatform.isDarwin "--parallel=1"}
    popd

    runHook postCheck
  '';

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    changelog = "https://docs.djangoproject.com/en/${lib.versions.majorMinor version}/releases/${version}/";
    description = "High-level Python Web framework that encourages rapid development and clean, pragmatic design";
    homepage = "https://www.djangoproject.com";
    license = licenses.bsd3;
    maintainers = with maintainers; [ hexa ];
  };
}
