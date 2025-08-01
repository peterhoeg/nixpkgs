{
  lib,
  atpublic,
  attrs,
  buildPythonPackage,
  fetchFromGitHub,
  pytest-mock,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  typing-extensions,

  # for passthru.tests
  django,
  aiosmtplib,
}:

buildPythonPackage rec {
  pname = "aiosmtpd";
  version = "1.4.6";
  pyproject = true;

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiosmtpd";
    tag = "v${version}";
    hash = "sha256-Ih/xbWM9O/fFQiZezydlPlIr36fLRc2lLgdfxD5Jviw=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    atpublic
    attrs
  ]
  ++ lib.optionals (pythonOlder "3.8") [ typing-extensions ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  # Fixes for Python 3.10 can't be applied easily, https://github.com/aio-libs/aiosmtpd/pull/294
  doCheck = pythonOlder "3.10";

  disabledTests = [
    # Requires git
    "test_ge_master"
    # Seems to be a sandbox issue
    "test_byclient"
  ];

  pythonImportsCheck = [ "aiosmtpd" ];

  passthru.tests = {
    inherit django aiosmtplib;
  };

  meta = with lib; {
    description = "Asyncio based SMTP server";
    mainProgram = "aiosmtpd";
    homepage = "https://aiosmtpd.readthedocs.io/";
    changelog = "https://github.com/aio-libs/aiosmtpd/releases/tag/v${version}";
    longDescription = ''
      This is a server for SMTP and related protocols, similar in utility to the
      standard library's smtpd.py module.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ eadwu ];
  };
}
