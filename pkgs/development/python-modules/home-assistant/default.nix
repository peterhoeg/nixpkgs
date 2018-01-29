{ stdenv, fetchFromGitHub, python, isPy3k
, extraPackages ? ps: []
, skipPip ? true }:

let

  py = python.override {
    packageOverrides = self: super: {
      yarl = super.yarl.overridePythonAttrs (oldAttrs: rec {
        version = "0.18.0";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "11j8symkxh0ngvpddqpj85qmk6p70p20jca3alxc181gk3vx785s";
        };
      });
      aiohttp = super.aiohttp.overridePythonAttrs (oldAttrs: rec {
        version = "2.3.7";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "0fzfpx5ny7559xrxaawnylq20dvrkjiag0ypcd13frwwivrlsagy";
        };
      });
      hass-frontend = super.callPackage ./frontend.nix { };
    };
  };

  # Ensure that we are using a consistent package set
  extraBuildInputs = extraPackages py.pkgs;

in with py.pkgs; buildPythonApplication rec {
  pname = "homeassistant";
  version = "0.62.0";

  diabled = !isPy3k;

  # PyPI tarball is missing tests/ directory
  src = fetchFromGitHub {
    owner = "home-assistant";
    repo = "home-assistant";
    rev = version;
    sha256 = "0m9cnrlia2f2cilrn4bf0xf59pni8ss4jahqbadl299jqwnh3qv4";
  };

  propagatedBuildInputs = [
    # From setup.py
    requests pyyaml pytz pip jinja2 voluptuous typing aiohttp yarl async-timeout chardet astral certifi
    # From the components that are part of the default configuration.yaml
    sqlalchemy aiohttp-cors hass-frontend user-agents distro mutagen xmltodict netdisco 
  ] ++ extraBuildInputs;

  checkInputs = [
    pytest requests-mock pydispatcher pytest-aiohttp
  ];

  checkPhase = ''
    # The components' dependencies are not included, so they cannot be tested
    py.test --ignore tests/components
    # Some basic components should be tested however
    py.test \
      tests/components/{group,http} \
      tests/components/test_{api,configurator,demo,discovery,frontend,init,introduction,logger,script,shell_command,system_log,websocket_api}.py
  '';

  makeWrapperArgs = [] ++ stdenv.lib.optional skipPip [ "--add-flags --skip-pip" ];

  meta = with stdenv.lib; {
    homepage = https://home-assistant.io/;
    description = "Open-source home automation platform running on Python 3";
    license = licenses.asl20;
    maintainers = with maintainers; [ f-breidenstein dotlambda ];
  };
}
