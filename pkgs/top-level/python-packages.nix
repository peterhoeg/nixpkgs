# This file contains the Python packages set.
# Each attribute is a Python library or a helper function.
# Expressions for Python libraries are supposed to be in `pkgs/development/python-modules/<name>/default.nix`.
# Python packages that do not need to be available for each interpreter version do not belong in this packages set.
# Examples are Python-based cli tools.
#
# For more details, please see the Python section in the Nixpkgs manual.

{ pkgs
, stdenv
, python
, overrides ? (self: super: {})
}:

with pkgs.lib;

let
  packages = ( self:

let
  inherit (python.passthru) isPy27 isPy33 isPy34 isPy35 isPy36 isPy37 isPy3k isPyPy pythonAtLeast pythonOlder;

  callPackage = pkgs.newScope self;

  namePrefix = python.libPrefix + "-";

  bootstrapped-pip = callPackage ../development/python-modules/bootstrapped-pip { };

  # Derivations built with `buildPythonPackage` can already be overriden with `override`, `overrideAttrs`, and `overrideDerivation`.
  # This function introduces `overridePythonAttrs` and it overrides the call to `buildPythonPackage`.
  makeOverridablePythonPackage = f: origArgs:
    let
      ff = f origArgs;
      overrideWith = newArgs: origArgs // (if pkgs.lib.isFunction newArgs then newArgs origArgs else newArgs);
    in
      if builtins.isAttrs ff then (ff // {
        overridePythonAttrs = newArgs: makeOverridablePythonPackage f (overrideWith newArgs);
      })
      else if builtins.isFunction ff then {
        overridePythonAttrs = newArgs: makeOverridablePythonPackage f (overrideWith newArgs);
        __functor = self: ff;
      }
      else ff;

  buildPythonPackage = makeOverridablePythonPackage ( makeOverridable (callPackage ../development/interpreters/python/build-python-package.nix {
    flit = self.flit;
    # We want Python libraries to be named like e.g. "python3.6-${name}"
    inherit namePrefix;
    inherit toPythonModule;
  }));

  buildPythonApplication = makeOverridablePythonPackage ( makeOverridable (callPackage ../development/interpreters/python/build-python-package.nix {
    flit = self.flit;
    namePrefix = "";
    toPythonModule = x: x; # Application does not provide modules.
  }));

  # See build-setupcfg/default.nix for documentation.
  buildSetupcfg = import ../build-support/build-setupcfg self;

  fetchPypi = makeOverridable( {format ? "setuptools", ... } @attrs:
    let
      fetchWheel = {pname, version, sha256, python ? "py2.py3", abi ? "none", platform ? "any"}:
      # Fetch a wheel. By default we fetch an universal wheel.
      # See https://www.python.org/dev/peps/pep-0427/#file-name-convention for details regarding the optional arguments.
        let
          url = "https://files.pythonhosted.org/packages/${python}/${builtins.substring 0 1 pname}/${pname}/${pname}-${version}-${python}-${abi}-${platform}.whl";
        in pkgs.fetchurl {inherit url sha256;};
      fetchSource = {pname, version, sha256, extension ? "tar.gz"}:
      # Fetch a source tarball.
        let
          url = "mirror://pypi/${builtins.substring 0 1 pname}/${pname}/${pname}-${version}.${extension}";
        in pkgs.fetchurl {inherit url sha256;};
      fetcher = (if format == "wheel" then fetchWheel
        else if format == "setuptools" then fetchSource
        else throw "Unsupported kind ${kind}");
    in fetcher (builtins.removeAttrs attrs ["format"]) );

  # Check whether a derivation provides a Python module.
  hasPythonModule = drv: drv?pythonModule && drv.pythonModule == python;

  # Get list of required Python modules given a list of derivations.
  requiredPythonModules = drvs: let
    modules = filter hasPythonModule drvs;
  in unique ([python] ++ modules ++ concatLists (catAttrs "requiredPythonModules" modules));

  # Create a PYTHONPATH from a list of derivations. This function recurses into the items to find derivations
  # providing Python modules.
  makePythonPath = drvs: stdenv.lib.makeSearchPath python.sitePackages (requiredPythonModules drvs);

  removePythonPrefix = name:
    removePrefix namePrefix name;

  # Convert derivation to a Python module.
  toPythonModule = drv:
    drv.overrideAttrs( oldAttrs: {
      # Use passthru in order to prevent rebuilds when possible.
      passthru = (oldAttrs.passthru or {})// {
        pythonModule = python;
        pythonPath = [ ]; # Deprecated, for compatibility.
        requiredPythonModules = requiredPythonModules drv.propagatedBuildInputs;
      };
    });

  # Convert a Python library to an application.
  toPythonApplication = drv:
    drv.overrideAttrs( oldAttrs: {
      passthru = (oldAttrs.passthru or {}) // {
        # Remove Python prefix from name so we have a "normal" name.
        # While the prefix shows up in the store path, it won't be
        # used by `nix-env`.
        name = removePythonPrefix oldAttrs.name;
        pythonModule = false;
      };
    });

  disabledIf = x: drv:
    if x then throw "${removePythonPrefix (drv.pname or drv.name)} not supported for interpreter ${python.executable}" else drv;

in {

  inherit (python.passthru) isPy27 isPy33 isPy34 isPy35 isPy36 isPy37 isPy3k isPyPy pythonAtLeast pythonOlder;
  inherit python bootstrapped-pip buildPythonPackage buildPythonApplication;
  inherit fetchPypi callPackage;
  inherit hasPythonModule requiredPythonModules makePythonPath disabledIf;
  inherit toPythonModule toPythonApplication;
  inherit buildSetupcfg;

  # helpers

  wrapPython = callPackage ../development/interpreters/python/wrap-python.nix {inherit python; inherit (pkgs) makeSetupHook makeWrapper; };

  # specials

  recursivePthLoader = callPackage ../development/python-modules/recursive-pth-loader { };

  setuptools = toPythonModule (callPackage ../development/python-modules/setuptools { });

  vowpalwabbit = callPackage ../development/python-modules/vowpalwabbit {
    boost = pkgs.boost160;
  };

  acoustics = callPackage ../development/python-modules/acoustics { };

  py3to2 = callPackage ../development/python-modules/3to2 { };
  # Left for backwards compatibility
  "3to2" = self.py3to2;

  absl-py = callPackage ../development/python-modules/absl-py { };

  aenum = callPackage ../development/python-modules/aenum { };

  affinity = callPackage ../development/python-modules/affinity { };

  agate = callPackage ../development/python-modules/agate { };

  agate-dbf = callPackage ../development/python-modules/agate-dbf { };

  alerta = callPackage ../development/python-modules/alerta { };

  alerta-server = callPackage ../development/python-modules/alerta-server { };

  phonenumbers = callPackage ../development/python-modules/phonenumbers { };

  agate-excel = callPackage ../development/python-modules/agate-excel { };

  agate-sql = callPackage ../development/python-modules/agate-sql { };

  aioimaplib = callPackage ../development/python-modules/aioimaplib { };

  aioamqp = callPackage ../development/python-modules/aioamqp { };

  ansicolor = callPackage ../development/python-modules/ansicolor { };

  argon2_cffi = callPackage ../development/python-modules/argon2_cffi { };

  asana = callPackage ../development/python-modules/asana { };

  ase = callPackage ../development/python-modules/ase { };

  asn1crypto = callPackage ../development/python-modules/asn1crypto { };

  aspy-yaml = callPackage ../development/python-modules/aspy.yaml { };

  astral = callPackage ../development/python-modules/astral { };

  astropy = callPackage ../development/python-modules/astropy { };

  astroquery = callPackage ../development/python-modules/astroquery { };

  atom = callPackage ../development/python-modules/atom { };

  augeas = callPackage ../development/python-modules/augeas {
    inherit (pkgs) augeas;
  };

  authres = callPackage ../development/python-modules/authres { };

  autograd = callPackage ../development/python-modules/autograd { };

  autologging = callPackage ../development/python-modules/autologging { };

  automat = callPackage ../development/python-modules/automat { };

  awkward = callPackage ../development/python-modules/awkward { };

  aws-sam-translator = callPackage ../development/python-modules/aws-sam-translator { };

  aws-xray-sdk = callPackage ../development/python-modules/aws-xray-sdk { };

  aws-adfs = callPackage ../development/python-modules/aws-adfs { };

  atomman = callPackage ../development/python-modules/atomman { };

  # packages defined elsewhere

  amazon_kclpy = callPackage ../development/python-modules/amazon_kclpy { };

  ansiconv = callPackage ../development/python-modules/ansiconv { };

  azure = callPackage ../development/python-modules/azure { };

  azure-nspkg = callPackage ../development/python-modules/azure-nspkg { };

  azure-common = callPackage ../development/python-modules/azure-common { };

  azure-mgmt-common = callPackage ../development/python-modules/azure-mgmt-common { };

  azure-mgmt-compute = callPackage ../development/python-modules/azure-mgmt-compute { };

  azure-mgmt-network = callPackage ../development/python-modules/azure-mgmt-network { };

  azure-mgmt-nspkg = callPackage ../development/python-modules/azure-mgmt-nspkg { };

  azure-mgmt-resource = callPackage ../development/python-modules/azure-mgmt-resource { };

  azure-mgmt-storage = callPackage ../development/python-modules/azure-mgmt-storage { };

  azure-storage = callPackage ../development/python-modules/azure-storage { };

  azure-servicemanagement-legacy = callPackage ../development/python-modules/azure-servicemanagement-legacy { };

  backports_csv = callPackage ../development/python-modules/backports_csv {};

  backports-shutil-which = callPackage ../development/python-modules/backports-shutil-which {};

  bap = callPackage ../development/python-modules/bap {
    bap = pkgs.ocamlPackages.bap;
  };

  bash_kernel = callPackage ../development/python-modules/bash_kernel { };

  bayespy = callPackage ../development/python-modules/bayespy { };

  bitarray = callPackage ../development/python-modules/bitarray { };

  bitcoinlib = callPackage ../development/python-modules/bitcoinlib { };

  bitcoin-price-api = callPackage ../development/python-modules/bitcoin-price-api { };

  blivet = callPackage ../development/python-modules/blivet { };

  boltons = callPackage ../development/python-modules/boltons { };

  breathe = callPackage ../development/python-modules/breathe { };

  brotli = callPackage ../development/python-modules/brotli { };

  broadlink = callPackage ../development/python-modules/broadlink { };

  browser-cookie3 = callPackage ../development/python-modules/browser-cookie3 { };

  browsermob-proxy = disabledIf isPy3k (callPackage ../development/python-modules/browsermob-proxy {});

  bt_proximity = callPackage ../development/python-modules/bt-proximity { };

  bugseverywhere = callPackage ../applications/version-management/bugseverywhere {};

  cachecontrol = callPackage ../development/python-modules/cachecontrol { };

  cachy = callPackage ../development/python-modules/cachy { };

  cdecimal = callPackage ../development/python-modules/cdecimal { };

  chalice = callPackage ../development/python-modules/chalice { };

  cleo = callPackage ../development/python-modules/cleo { };

  clikit = callPackage ../development/python-modules/clikit { };

  clustershell = callPackage ../development/python-modules/clustershell { };

  cozy = callPackage ../development/python-modules/cozy { };

  dendropy = callPackage ../development/python-modules/dendropy { };

  dependency-injector = callPackage ../development/python-modules/dependency-injector { };

  btchip = callPackage ../development/python-modules/btchip { };

  datamodeldict = callPackage ../development/python-modules/datamodeldict { };

  dbf = callPackage ../development/python-modules/dbf { };

  dbfread = callPackage ../development/python-modules/dbfread { };

  deap = callPackage ../development/python-modules/deap { };

  dkimpy = callPackage ../development/python-modules/dkimpy { };

  dictionaries = callPackage ../development/python-modules/dictionaries { };

  diff_cover = callPackage ../development/python-modules/diff_cover { };

  docrep = callPackage ../development/python-modules/docrep { };

  dominate = callPackage ../development/python-modules/dominate { };

  emcee = callPackage ../development/python-modules/emcee { };

  email_validator = callPackage ../development/python-modules/email-validator { };

  ewmh = callPackage ../development/python-modules/ewmh { };

  exchangelib = callPackage ../development/python-modules/exchangelib { };

  dbus-python = callPackage ../development/python-modules/dbus {
    dbus = pkgs.dbus;
  };

  dftfit = callPackage ../development/python-modules/dftfit { };

  discid = callPackage ../development/python-modules/discid { };

  discordpy = callPackage ../development/python-modules/discordpy { };

  parver = callPackage ../development/python-modules/parver { };
  arpeggio = callPackage ../development/python-modules/arpeggio { };
  invoke = callPackage ../development/python-modules/invoke { };

  distorm3 = callPackage ../development/python-modules/distorm3 { };

  distributed = callPackage ../development/python-modules/distributed { };

  docutils = callPackage ../development/python-modules/docutils { };

  dogtail = callPackage ../development/python-modules/dogtail { };

  diff-match-patch = callPackage ../development/python-modules/diff-match-patch { };

  eradicate = callPackage ../development/python-modules/eradicate {  };

  face = callPackage ../development/python-modules/face { };

  fastpbkdf2 = callPackage ../development/python-modules/fastpbkdf2 {  };

  fido2 = callPackage ../development/python-modules/fido2 {  };

  filterpy = callPackage ../development/python-modules/filterpy { };

  fints = callPackage ../development/python-modules/fints { };

  fire = callPackage ../development/python-modules/fire { };

  fdint = callPackage ../development/python-modules/fdint { };

  fuse = callPackage ../development/python-modules/fuse-python { fuse = pkgs.fuse; };

  genanki = callPackage ../development/python-modules/genanki { };

  gidgethub = callPackage ../development/python-modules/gidgethub { };

  gin-config = callPackage ../development/python-modules/gin-config { };

  globus-sdk = callPackage ../development/python-modules/globus-sdk { };

  glom = callPackage ../development/python-modules/glom { };

  goocalendar = callPackage ../development/python-modules/goocalendar { };

  gsd = callPackage ../development/python-modules/gsd { };

  gssapi = callPackage ../development/python-modules/gssapi { };

  h5py = callPackage ../development/python-modules/h5py {
    hdf5 = pkgs.hdf5;
  };

  h5py-mpi = self.h5py.override {
    hdf5 = pkgs.hdf5-mpi;
  };

  ha-ffmpeg = callPackage ../development/python-modules/ha-ffmpeg { };

  habanero = callPackage ../development/python-modules/habanero { };

  helper = callPackage ../development/python-modules/helper { };

  histbook = callPackage ../development/python-modules/histbook { };

  hdmedians = callPackage ../development/python-modules/hdmedians { };

  hoomd-blue = toPythonModule (callPackage ../development/python-modules/hoomd-blue {
    inherit python;
  });

  hopcroftkarp = callPackage ../development/python-modules/hopcroftkarp { };

  httpsig = callPackage ../development/python-modules/httpsig { };

  i3ipc = callPackage ../development/python-modules/i3ipc { };

  imutils = callPackage ../development/python-modules/imutils { };

  intelhex = callPackage ../development/python-modules/intelhex { };

  jira = callPackage ../development/python-modules/jira { };

  jwcrypto = callPackage ../development/python-modules/jwcrypto { };

  lammps-cython = callPackage ../development/python-modules/lammps-cython {
    mpi = pkgs.openmpi;
  };

  libmr = callPackage ../development/python-modules/libmr { };

  lmtpd = callPackage ../development/python-modules/lmtpd { };

  logster = callPackage ../development/python-modules/logster { };

  mail-parser = callPackage ../development/python-modules/mail-parser { };

  manhole = callPackage ../development/python-modules/manhole { };

  markerlib = callPackage ../development/python-modules/markerlib { };

  matchpy = callPackage ../development/python-modules/matchpy { };

  monty = callPackage ../development/python-modules/monty { };

  mininet-python = (toPythonModule (pkgs.mininet.override{ inherit python; })).py;

  mpi4py = callPackage ../development/python-modules/mpi4py {
    mpi = pkgs.openmpi;
  };

  multiset = callPackage ../development/python-modules/multiset { };

  mwclient = callPackage ../development/python-modules/mwclient { };

  mwoauth = callPackage ../development/python-modules/mwoauth { };

  nbval = callPackage ../development/python-modules/nbval { };

  nest-asyncio = callPackage ../development/python-modules/nest-asyncio { };

  neuron = pkgs.neuron.override {
    inherit python;
  };

  neuron-mpi = pkgs.neuron-mpi.override {
    inherit python;
  };

  nixpart = callPackage ../tools/filesystems/nixpart { };

  # This is used for NixOps to make sure we won't break it with the next major
  # version of nixpart.
  nixpart0 = callPackage ../tools/filesystems/nixpart/0.4 { };

  nltk = callPackage ../development/python-modules/nltk { };

  ntlm-auth = callPackage ../development/python-modules/ntlm-auth { };

  nvchecker = callPackage ../development/python-modules/nvchecker { };

  numericalunits = callPackage ../development/python-modules/numericalunits { };

  oauthenticator = callPackage ../development/python-modules/oauthenticator { };

  ordered-set = callPackage ../development/python-modules/ordered-set { };

  osmnx = callPackage ../development/python-modules/osmnx { };

  outcome = callPackage ../development/python-modules/outcome {};

  ovito = toPythonModule (pkgs.libsForQt5.callPackage ../development/python-modules/ovito {
      pythonPackages = self;
    });

  palettable = callPackage ../development/python-modules/palettable { };

  pastel = callPackage ../development/python-modules/pastel { };

  pathlib = callPackage ../development/python-modules/pathlib { };

  pdf2image = callPackage ../development/python-modules/pdf2image { };

  pdfminer = callPackage ../development/python-modules/pdfminer_six { };

  pdfx = callPackage ../development/python-modules/pdfx { };

  perf = callPackage ../development/python-modules/perf { };

  phonopy = callPackage ../development/python-modules/phonopy { };

  pims = callPackage ../development/python-modules/pims { };

  plantuml = callPackage ../tools/misc/plantuml { };

  poetry = callPackage ../development/python-modules/poetry { };

  progress = callPackage ../development/python-modules/progress { };

  pymysql = callPackage ../development/python-modules/pymysql { };

  Pmw = callPackage ../development/python-modules/Pmw { };

  py_stringmatching = callPackage ../development/python-modules/py_stringmatching { };

  pyaes = callPackage ../development/python-modules/pyaes { };

  pyairvisual = callPackage ../development/python-modules/pyairvisual { };

  pyamf = callPackage ../development/python-modules/pyamf { };

  pyarrow = callPackage ../development/python-modules/pyarrow {
    inherit (pkgs) arrow-cpp cmake pkgconfig;
  };

  pyannotate = callPackage ../development/python-modules/pyannotate { };

  pyatspi = callPackage ../development/python-modules/pyatspi { };

  pyaxmlparser = callPackage ../development/python-modules/pyaxmlparser { };

  pycairo = callPackage ../development/python-modules/pycairo { };

  pycangjie = disabledIf (!isPy3k) (callPackage ../development/python-modules/pycangjie { });

  pycrc = callPackage ../development/python-modules/pycrc { };

  pycrypto = callPackage ../development/python-modules/pycrypto { };

  pycryptodome = callPackage ../development/python-modules/pycryptodome { };

  pycryptodomex = callPackage ../development/python-modules/pycryptodomex { };

  PyChromecast = callPackage ../development/python-modules/pychromecast { };

  py-cpuinfo = callPackage ../development/python-modules/py-cpuinfo { };

  pydbus = callPackage ../development/python-modules/pydbus { };

  pydocstyle = callPackage ../development/python-modules/pydocstyle { };

  pyexiv2 = disabledIf isPy3k (toPythonModule (callPackage ../development/python-modules/pyexiv2 {}));

  py3exiv2 = callPackage ../development/python-modules/py3exiv2 { };

  pyfakefs = callPackage ../development/python-modules/pyfakefs {};

  pyfttt = callPackage ../development/python-modules/pyfttt { };

  pygame = callPackage ../development/python-modules/pygame { };

  pygame-git = callPackage ../development/python-modules/pygame/git.nix { };

  pygame_sdl2 = callPackage ../development/python-modules/pygame_sdl2 { };

  pygdbmi = callPackage ../development/python-modules/pygdbmi { };

  pygmo = callPackage ../development/python-modules/pygmo { };

  pygobject2 = callPackage ../development/python-modules/pygobject { };

  pygobject3 = callPackage ../development/python-modules/pygobject/3.nix { };

  pygtail = callPackage ../development/python-modules/pygtail { };

  pygtk = callPackage ../development/python-modules/pygtk { libglade = null; };

  pygtksourceview = callPackage ../development/python-modules/pygtksourceview { };

  pyGtkGlade = self.pygtk.override {
    libglade = pkgs.gnome2.libglade;
  };

  pyjwkest = callPackage ../development/python-modules/pyjwkest { };

  pykde4 = callPackage ../development/python-modules/pykde4 {
    inherit (self) pyqt4;
    callPackage = pkgs.callPackage;
  };

  pykdtree = callPackage ../development/python-modules/pykdtree {
    inherit (pkgs.llvmPackages) openmp;
  };

  pykerberos = callPackage ../development/python-modules/pykerberos { };

  pykeepass = callPackage ../development/python-modules/pykeepass { };

  pylev = callPackage ../development/python-modules/pylev { };

  pymatgen = callPackage ../development/python-modules/pymatgen { };

  pymatgen-lammps = callPackage ../development/python-modules/pymatgen-lammps { };

  pymsgbox = callPackage ../development/python-modules/pymsgbox { };

  pynisher = callPackage ../development/python-modules/pynisher { };

  pyparser = callPackage ../development/python-modules/pyparser { };

  pyres = callPackage ../development/python-modules/pyres { };

  pyqt4 = callPackage ../development/python-modules/pyqt/4.x.nix {
    pythonPackages = self;
  };

  pyqt5 = pkgs.libsForQt5.callPackage ../development/python-modules/pyqt/5.x.nix {
    pythonPackages = self;
  };

  /*
    `pyqt5_with_qtwebkit` should not be used by python libraries in
    pkgs/development/python-modules/*. Putting this attribute in
    `propagatedBuildInputs` may cause collisions.
  */
  pyqt5_with_qtwebkit = self.pyqt5.override { withWebKit = true; };

  pysc2 = callPackage ../development/python-modules/pysc2 { };

  pyscard = callPackage ../development/python-modules/pyscard { inherit (pkgs.darwin.apple_sdk.frameworks) PCSC; };

  pyside = callPackage ../development/python-modules/pyside { };

  pysideShiboken = callPackage ../development/python-modules/pyside/shiboken.nix {
    inherit (pkgs) libxml2 libxslt; # Do not need the Python bindings.
  };

  pysideTools = callPackage ../development/python-modules/pyside/tools.nix { };

  pyslurm = callPackage ../development/python-modules/pyslurm {
    slurm = pkgs.slurm;
  };

  pyssim = callPackage ../development/python-modules/pyssim { };

  pystache = callPackage ../development/python-modules/pystache { };

  pytesseract = callPackage ../development/python-modules/pytesseract { };

  pytest-mypy = callPackage ../development/python-modules/pytest-mypy { };

  pytest-tornado = callPackage ../development/python-modules/pytest-tornado { };

  python-binance = callPackage ../development/python-modules/python-binance { };

  python-engineio = callPackage ../development/python-modules/python-engineio { };

  python-hosts = callPackage ../development/python-modules/python-hosts { };

  python-lz4 = callPackage ../development/python-modules/python-lz4 { };
  lz4 = self.python-lz4; # alias 2018-12-05

  python-ldap-test = callPackage ../development/python-modules/python-ldap-test { };

  python-mnist = callPackage ../development/python-modules/python-mnist { };

  python-igraph = callPackage ../development/python-modules/python-igraph {
    pkgconfig = pkgs.pkgconfig;
    igraph = pkgs.igraph;
  };

  python3-openid = callPackage ../development/python-modules/python3-openid { };

  python-packer = callPackage ../development/python-modules/python-packer { };

  python-periphery = callPackage ../development/python-modules/python-periphery { };

  python-prctl = callPackage ../development/python-modules/python-prctl { };

  python-rapidjson = callPackage ../development/python-modules/python-rapidjson { };

  python-sql = callPackage ../development/python-modules/python-sql { };

  python-stdnum = callPackage ../development/python-modules/python-stdnum { };

  python-socketio = callPackage ../development/python-modules/python-socketio { };

  python-utils = callPackage ../development/python-modules/python-utils { };

  pytimeparse =  callPackage ../development/python-modules/pytimeparse { };

  PyWebDAV = callPackage ../development/python-modules/pywebdav { };

  pyxml = disabledIf isPy3k (callPackage ../development/python-modules/pyxml{ });

  pyvcd = callPackage ../development/python-modules/pyvcd { };

  pyvoro = callPackage ../development/python-modules/pyvoro { };

  relatorio = callPackage ../development/python-modules/relatorio { };

  remotecv = callPackage ../development/python-modules/remotecv { };

  pyzufall = callPackage ../development/python-modules/pyzufall { };

  rhpl = disabledIf isPy3k (callPackage ../development/python-modules/rhpl {});

  rlp = callPackage ../development/python-modules/rlp { };

  rx = callPackage ../development/python-modules/rx { };

  sabyenc = callPackage ../development/python-modules/sabyenc { };

  salmon-mail = callPackage ../development/python-modules/salmon-mail { };

  seekpath = callPackage ../development/python-modules/seekpath { };

  selectors2 = callPackage ../development/python-modules/selectors2 { };

  sepaxml = callPackage ../development/python-modules/sepaxml { };

  serversyncstorage = callPackage ../development/python-modules/serversyncstorage {};

  shellingham = callPackage ../development/python-modules/shellingham {};

  simpleeval = callPackage ../development/python-modules/simpleeval { };

  singledispatch = callPackage ../development/python-modules/singledispatch { };

  sip = callPackage ../development/python-modules/sip { };

  sortedcontainers = callPackage ../development/python-modules/sortedcontainers { };

  sklearn-deap = callPackage ../development/python-modules/sklearn-deap { };

  slackclient = callPackage ../development/python-modules/slackclient { };

  slicerator = callPackage ../development/python-modules/slicerator { };

  slither-analyzer = callPackage ../development/python-modules/slither-analyzer { };

  snapcast = callPackage ../development/python-modules/snapcast { };

  spglib = callPackage ../development/python-modules/spglib { };

  sslib = callPackage ../development/python-modules/sslib { };

  statistics = callPackage ../development/python-modules/statistics { };

  sumo = callPackage ../development/python-modules/sumo { };

  supervise_api = callPackage ../development/python-modules/supervise_api { };

  syncserver = callPackage ../development/python-modules/syncserver {};

  tables = callPackage ../development/python-modules/tables {
    hdf5 = pkgs.hdf5.override { zlib = pkgs.zlib; };
  };

  trueskill = callPackage ../development/python-modules/trueskill { };

  trustme = callPackage ../development/python-modules/trustme {};

  trio = callPackage ../development/python-modules/trio {};

  sniffio = callPackage ../development/python-modules/sniffio { };

  tokenserver = callPackage ../development/python-modules/tokenserver {};

  toml = callPackage ../development/python-modules/toml { };

  tomlkit = callPackage ../development/python-modules/tomlkit { };

  unifi = callPackage ../development/python-modules/unifi { };

  vidstab = callPackage ../development/python-modules/vidstab { };

  webapp2 = callPackage ../development/python-modules/webapp2 { };

  pyunbound = callPackage ../tools/networking/unbound/python.nix { };

  WazeRouteCalculator = callPackage ../development/python-modules/WazeRouteCalculator { };

  yarg = callPackage ../development/python-modules/yarg { };

  # packages defined here

  aafigure = callPackage ../development/python-modules/aafigure { };

  altair = callPackage ../development/python-modules/altair { };

  vega = callPackage ../development/python-modules/vega { };

  acme = callPackage ../development/python-modules/acme { };

  acme-tiny = callPackage ../development/python-modules/acme-tiny { };

  actdiag = callPackage ../development/python-modules/actdiag { };

  adal = callPackage ../development/python-modules/adal { };

  affine = callPackage ../development/python-modules/affine { };

  aioconsole = callPackage ../development/python-modules/aioconsole { };

  aiodns = callPackage ../development/python-modules/aiodns { };

  aiofiles = callPackage ../development/python-modules/aiofiles { };

  aioh2 = callPackage ../development/python-modules/aioh2 { };

  aiohttp = callPackage ../development/python-modules/aiohttp { };

  aiohttp-cors = callPackage ../development/python-modules/aiohttp/cors.nix { };

  aiohttp-jinja2 = callPackage ../development/python-modules/aiohttp-jinja2 { };

  aiohttp-remotes = callPackage ../development/python-modules/aiohttp-remotes { };

  aioprocessing = callPackage ../development/python-modules/aioprocessing { };

  ajpy = callPackage ../development/python-modules/ajpy { };

  alabaster = callPackage ../development/python-modules/alabaster {};

  alembic = callPackage ../development/python-modules/alembic {};

  allpairspy = callPackage ../development/python-modules/allpairspy { };

  ansicolors = callPackage ../development/python-modules/ansicolors {};

  aniso8601 = callPackage ../development/python-modules/aniso8601 {};

  asgiref = callPackage ../development/python-modules/asgiref { };

  python-editor = callPackage ../development/python-modules/python-editor { };

  python-gnupg = callPackage ../development/python-modules/python-gnupg {};

  python-uinput = callPackage ../development/python-modules/python-uinput {};

  python-sybase = callPackage ../development/python-modules/sybase {};

  alot = callPackage ../development/python-modules/alot {};

  anyjson = callPackage ../development/python-modules/anyjson {};

  amqp = callPackage ../development/python-modules/amqp {};

  amqplib = callPackage ../development/python-modules/amqplib {};

  antlr4-python3-runtime = callPackage ../development/python-modules/antlr4-python3-runtime {};

  apipkg = callPackage ../development/python-modules/apipkg {};

  appdirs = callPackage ../development/python-modules/appdirs { };

  appleseed = disabledIf isPy3k
    (toPythonModule (pkgs.appleseed.override {
      inherit (self) python;
    }));

  application = callPackage ../development/python-modules/application { };

  appnope = callPackage ../development/python-modules/appnope { };

  approvaltests = callPackage ../development/python-modules/approvaltests { };

  apsw = callPackage ../development/python-modules/apsw {};

  astor = callPackage ../development/python-modules/astor {};

  asyncio = callPackage ../development/python-modules/asyncio {};

  asyncssh = callPackage ../development/python-modules/asyncssh { };

  python-fontconfig = callPackage ../development/python-modules/python-fontconfig { };

  funcsigs = callPackage ../development/python-modules/funcsigs { };

  APScheduler = callPackage ../development/python-modules/APScheduler { };

  args = callPackage ../development/python-modules/args { };

  argcomplete = callPackage ../development/python-modules/argcomplete { };

  area53 = callPackage ../development/python-modules/area53 { };

  arxiv2bib = callPackage ../development/python-modules/arxiv2bib { };

  chai = callPackage ../development/python-modules/chai { };

  chainmap = callPackage ../development/python-modules/chainmap { };

  arelle = callPackage ../development/python-modules/arelle {
    gui = true;
  };

  arelle-headless = callPackage ../development/python-modules/arelle {
    gui = false;
  };

  deluge-client = callPackage ../development/python-modules/deluge-client { };

  arrow = callPackage ../development/python-modules/arrow { };

  asynctest = callPackage ../development/python-modules/asynctest { };

  async-timeout = callPackage ../development/python-modules/async_timeout { };

  async_generator = callPackage ../development/python-modules/async_generator { };

  asn1ate = callPackage ../development/python-modules/asn1ate { };

  atomiclong = callPackage ../development/python-modules/atomiclong { };

  atomicwrites = callPackage ../development/python-modules/atomicwrites { };

  # argparse is part of stdlib in 2.7 and 3.2+
  argparse = null;

  astroid = if isPy3k then callPackage ../development/python-modules/astroid { }
            else callPackage ../development/python-modules/astroid/1.6.nix { };

  attrdict = callPackage ../development/python-modules/attrdict { };

  attrs = callPackage ../development/python-modules/attrs { };

  atsim_potentials = callPackage ../development/python-modules/atsim_potentials { };

  audioread = callPackage ../development/python-modules/audioread { };

  audiotools = callPackage ../development/python-modules/audiotools { };

  autopep8 = callPackage ../development/python-modules/autopep8 { };

  av = callPackage ../development/python-modules/av { };

  avro = callPackage ../development/python-modules/avro {};

  avro3k = callPackage ../development/python-modules/avro3k {};

  python-slugify = callPackage ../development/python-modules/python-slugify { };

  awesome-slugify = callPackage ../development/python-modules/awesome-slugify {};

  noise = callPackage ../development/python-modules/noise {};

  backcall = callPackage ../development/python-modules/backcall { };

  backports_abc = callPackage ../development/python-modules/backports_abc { };

  backports_functools_lru_cache = callPackage ../development/python-modules/backports_functools_lru_cache { };

  backports_os = callPackage ../development/python-modules/backports_os { };

  backports_shutil_get_terminal_size = callPackage ../development/python-modules/backports_shutil_get_terminal_size { };

  backports_ssl_match_hostname = if !(pythonOlder "3.5") then null else
    callPackage ../development/python-modules/backports_ssl_match_hostname { };

  backports_lzma = callPackage ../development/python-modules/backports_lzma { };

  backports_tempfile = callPackage ../development/python-modules/backports_tempfile { };

  backports_unittest-mock = callPackage ../development/python-modules/backports_unittest-mock {};

  babelfish = callPackage ../development/python-modules/babelfish {};

  basiciw = callPackage ../development/python-modules/basiciw {
    inherit (pkgs) gcc wirelesstools;
  };

  base58 = callPackage ../development/python-modules/base58 {};

  batinfo = callPackage ../development/python-modules/batinfo {};

  bcdoc = callPackage ../development/python-modules/bcdoc {};

  beancount = callPackage ../development/python-modules/beancount { };

  beautifulsoup4 = callPackage ../development/python-modules/beautifulsoup4 { };

  beaker = callPackage ../development/python-modules/beaker { };

  betamax = callPackage ../development/python-modules/betamax {};

  betamax-matchers = callPackage ../development/python-modules/betamax-matchers { };

  betamax-serializers = callPackage ../development/python-modules/betamax-serializers { };

  bibtexparser = callPackage ../development/python-modules/bibtexparser { };

  binwalk = callPackage ../development/python-modules/binwalk { };

  binwalk-full = appendToName "full" (self.binwalk.override {
    pyqtgraph = self.pyqtgraph;
  });

  bitmath = callPackage ../development/python-modules/bitmath { };

  caldavclientlibrary-asynk = callPackage ../development/python-modules/caldavclientlibrary-asynk { };

  biopython = callPackage ../development/python-modules/biopython { };

  bedup = callPackage ../development/python-modules/bedup { };

  blessed = callPackage ../development/python-modules/blessed {};

  block-io = callPackage ../development/python-modules/block-io {};

  # Build boost for this specific Python version
  # TODO: use separate output for libboost_python.so
  boost = toPythonModule (pkgs.boost.override {
    inherit (self) python numpy;
    enablePython = true;
  });

  boltztrap2 = callPackage ../development/python-modules/boltztrap2 { };

  bumps = callPackage ../development/python-modules/bumps {};

  cached-property = callPackage ../development/python-modules/cached-property { };

  caffe = pkgs.caffe.override {
    python = self.python;
    boost = self.boost;
    numpy = self.numpy;
  };

  capstone = callPackage ../development/python-modules/capstone { };

  cement = callPackage ../development/python-modules/cement {};

  cgroup-utils = callPackage ../development/python-modules/cgroup-utils {};

  chainer = callPackage ../development/python-modules/chainer {
    cudaSupport = pkgs.config.cudaSupport or false;
  };

  channels = callPackage ../development/python-modules/channels {};

  cheroot = callPackage ../development/python-modules/cheroot {};

  cli-helpers = callPackage ../development/python-modules/cli-helpers {};

  cmarkgfm = callPackage ../development/python-modules/cmarkgfm { };

  circus = callPackage ../development/python-modules/circus {};

  colorclass = callPackage ../development/python-modules/colorclass {};

  colorlog = callPackage ../development/python-modules/colorlog { };

  colour = callPackage ../development/python-modules/colour {};

  configshell = callPackage ../development/python-modules/configshell { };

  constantly = callPackage ../development/python-modules/constantly { };

  cornice = callPackage ../development/python-modules/cornice { };

  cram = callPackage ../development/python-modules/cram { };

  csscompressor = callPackage ../development/python-modules/csscompressor {};

  csvkit =  callPackage ../development/python-modules/csvkit { };

  cufflinks = callPackage ../development/python-modules/cufflinks { };

  cupy = callPackage ../development/python-modules/cupy {
    cudatoolkit = pkgs.cudatoolkit_8;
    cudnn = pkgs.cudnn6_cudatoolkit_8;
    nccl = pkgs.nccl;
  };

  cx_Freeze = callPackage ../development/python-modules/cx_freeze {};

  cx_oracle = callPackage ../development/python-modules/cx_oracle {};

  cvxopt = callPackage ../development/python-modules/cvxopt { };

  cycler = callPackage ../development/python-modules/cycler { };

  cysignals = callPackage ../development/python-modules/cysignals { };

  cypari2 = callPackage ../development/python-modules/cypari2 { };

  dlib = callPackage ../development/python-modules/dlib {
    inherit (pkgs) dlib;
  };

  datadog = callPackage ../development/python-modules/datadog {};

  dataclasses = callPackage ../development/python-modules/dataclasses { };

  debian = callPackage ../development/python-modules/debian {};

  defusedxml = callPackage ../development/python-modules/defusedxml {};

  dugong = callPackage ../development/python-modules/dugong {};

  iowait = callPackage ../development/python-modules/iowait {};

  responses = callPackage ../development/python-modules/responses {};

  rarfile = callPackage ../development/python-modules/rarfile { inherit (pkgs) libarchive; };

  proboscis = callPackage ../development/python-modules/proboscis {};

  py4j = callPackage ../development/python-modules/py4j { };

  pyechonest = callPackage ../development/python-modules/pyechonest { };

  pyepsg = callPackage ../development/python-modules/pyepsg { };

  pyezminc = callPackage ../development/python-modules/pyezminc { };

  billiard = callPackage ../development/python-modules/billiard { };

  binaryornot = callPackage ../development/python-modules/binaryornot { };

  bitbucket_api = callPackage ../development/python-modules/bitbucket-api { };

  bitbucket-cli = callPackage ../development/python-modules/bitbucket-cli { };

  bitstring = callPackage ../development/python-modules/bitstring { };

  blaze = callPackage ../development/python-modules/blaze { };

  html5-parser = callPackage ../development/python-modules/html5-parser {};

  httpserver = callPackage ../development/python-modules/httpserver {};

  bleach = callPackage ../development/python-modules/bleach { };

  blinker = callPackage ../development/python-modules/blinker { };

  blockdiag = callPackage ../development/python-modules/blockdiag { };

  blockdiagcontrib-cisco = callPackage ../development/python-modules/blockdiagcontrib-cisco { };

  bpython = callPackage ../development/python-modules/bpython {};

  bsddb3 = callPackage ../development/python-modules/bsddb3 { };

  bkcharts = callPackage ../development/python-modules/bkcharts { };

  bokeh = callPackage ../development/python-modules/bokeh { };

  boto = callPackage ../development/python-modules/boto { };

  boto3 = callPackage ../development/python-modules/boto3 { };

  botocore = callPackage ../development/python-modules/botocore { };

  bottle = callPackage ../development/python-modules/bottle { };

  box2d = callPackage ../development/python-modules/box2d { pkgs-box2d = pkgs.box2d; };

  branca = callPackage ../development/python-modules/branca { };

  bugwarrior = callPackage ../development/python-modules/bugwarrior { };

  bugz = callPackage ../development/python-modules/bugz { };

  bugzilla = callPackage ../development/python-modules/bugzilla { };

  buildbot = callPackage ../development/python-modules/buildbot { };
  buildbot-plugins = pkgs.recurseIntoAttrs (callPackage ../development/python-modules/buildbot/plugins.nix { });
  buildbot-ui = self.buildbot.withPlugins (with self.buildbot-plugins; [ www ]);
  buildbot-full = self.buildbot.withPlugins (with self.buildbot-plugins; [ www console-view waterfall-view grid-view wsgi-dashboards ]);
  buildbot-worker = callPackage ../development/python-modules/buildbot/worker.nix { };
  buildbot-pkg = callPackage ../development/python-modules/buildbot/pkg.nix { };

  check-manifest = callPackage ../development/python-modules/check-manifest { };

  devpi-common = callPackage ../development/python-modules/devpi-common { };
  # A patched version of buildout, useful for buildout based development on Nix
  zc_buildout_nix = callPackage ../development/python-modules/buildout-nix { };

  zc_buildout = self.zc_buildout221;

  zc_buildout221 = callPackage ../development/python-modules/buildout { };

  bunch = callPackage ../development/python-modules/bunch { };

  can = callPackage ../development/python-modules/can {};

  canopen = callPackage ../development/python-modules/canopen {};

  canmatrix = callPackage ../development/python-modules/canmatrix {};

  cairocffi = callPackage ../development/python-modules/cairocffi {};

  cairosvg1 = callPackage ../development/python-modules/cairosvg/1_x.nix {};

  cairosvg = callPackage ../development/python-modules/cairosvg {};

  carrot = callPackage ../development/python-modules/carrot {};

  cartopy = callPackage ../development/python-modules/cartopy {};

  case = callPackage ../development/python-modules/case {};

  cbor = callPackage ../development/python-modules/cbor {};

  cassandra-driver = callPackage ../development/python-modules/cassandra-driver { };

  cccolutils = callPackage ../development/python-modules/cccolutils {};

  cchardet = callPackage ../development/python-modules/cchardet { };

  CDDB = callPackage ../development/python-modules/cddb { };

  cntk = callPackage ../development/python-modules/cntk { };

  celery = callPackage ../development/python-modules/celery { };

  cerberus = callPackage ../development/python-modules/cerberus { };

  CommonMark_54 = self.CommonMark.overridePythonAttrs (oldAttrs: rec {
    version = "0.5.4";
    src = oldAttrs.src.override {
      inherit version;
      sha256 = "34d73ec8085923c023930dfc0bcd1c4286e28a2a82de094bb72fabcc0281cbe5";
    };
  });


  coilmq = buildPythonPackage (rec {
    name = "CoilMQ-${version}";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/C/CoilMQ/${name}.tar.gz";
      sha256 = "0wwa6fsqw1mxsryvgp0yrdjil8axyj0kslzi7lr45cnhgp5ab375";
    };

    propagatedBuildInputs = with self; [ stompclient pythondaemon redis pid];

    buildInputs = with self; [ pytest six click coverage sqlalchemy ];

    # The teste data is not included in the distribution
    doCheck = false;

    meta = {
      description = "Simple, lightweight, and easily extensible STOMP message broker";
      homepage = http://code.google.com/p/coilmq/;
      license = licenses.asl20;
    };
  });


  colander = callPackage ../development/python-modules/colander { };

  # Backported version of the ConfigParser library of Python 3.3
  configparser = if isPy3k then null else buildPythonPackage rec {
    name = "configparser-${version}";
    version = "3.5.0";

    # running install_egg_info
    # error: [Errno 9] Bad file descriptor: '<stdout>'
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/c/configparser/${name}.tar.gz";
      sha256 = "5308b47021bc2340965c371f0f058cc6971a04502638d4244225c49d80db273a";
    };

    # No tests available
    doCheck = false;

    # Fix issue when used together with other namespace packages
    # https://github.com/NixOS/nixpkgs/issues/23855
    patches = [
      ./../development/python-modules/configparser/0001-namespace-fix.patch
    ];

    meta = {
      maintainers = [ ];
      platforms = platforms.all;
    };
  };


  ColanderAlchemy = buildPythonPackage rec {
    name = "ColanderAlchemy-${version}";
    version = "0.3.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/C/ColanderAlchemy/${name}.tar.gz";
      sha256 = "11wcni2xmfmy001rj62q2pwf305vvngkrfm5c4zlwvgbvlsrvnnw";
    };

    patches = [
      (pkgs.fetchpatch {
          url = "https://github.com/stefanofontanelli/ColanderAlchemy/commit/b45fe35f2936a5ccb705e9344075191e550af6c9.patch";
          sha256 = "1kf278wjq49zd6fhpp55vdcawzdd107767shzfck522sv8gr6qvx";
      })
    ];

    buildInputs = with self; [ unittest2 ];
    propagatedBuildInputs = with self; [ colander sqlalchemy ];

    meta = {
      description = "Autogenerate Colander schemas based on SQLAlchemy models";
      homepage = https://github.com/stefanofontanelli/ColanderAlchemy;
      license = licenses.mit;
    };
  };

  conda = callPackage ../development/python-modules/conda { };

  configobj = buildPythonPackage (rec {
    name = "configobj-5.0.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/c/configobj/${name}.tar.gz";
      sha256 = "a2f5650770e1c87fb335af19a9b7eb73fc05ccf22144eb68db7d00cd2bcb0902";
    };

    # error: invalid command 'test'
    doCheck = false;

    propagatedBuildInputs = with self; [ six ];

    meta = {
      description = "Config file reading, writing and validation";
      homepage = https://pypi.python.org/pypi/configobj;
      license = licenses.bsd3;
      maintainers = with maintainers; [ garbas ];
    };
  });


  confluent-kafka = callPackage ../development/python-modules/confluent-kafka {};

  kafka-python = callPackage ../development/python-modules/kafka-python {};

  construct = callPackage ../development/python-modules/construct {};

  consul = buildPythonPackage (rec {
    name = "python-consul-0.7.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-consul/${name}.tar.gz";
      sha256 = "18gs5myk9wkkq5zvj0n0s68ngj3mrbdcifshxfj1j0bgb1km0wpm";
    };

    buildInputs = with self; [ requests six pytest ];

    # No tests distributed. https://github.com/cablehead/python-consul/issues/133
    doCheck = false;

    meta = {
      description = "Python client for Consul (https://www.consul.io/)";
      homepage = https://github.com/cablehead/python-consul;
      license = licenses.mit;
      maintainers = with maintainers; [ desiderius ];
    };
  });

  contexter = buildPythonPackage rec {
    name = "contexter-${version}";
    version = "0.1.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/c/contexter/${name}.tar.gz";
      sha256 = "0xrnkjya29ya0hkj8y4k9ni2mnr58i6r0xfqlj7wk07v4jfrkc8n";
    };
  };


  contextlib2 = callPackage ../development/python-modules/contextlib2 { };

  cookiecutter = buildPythonPackage rec {
    version = "1.4.0";
    name = "cookiecutter-${version}";

    # not sure why this is broken
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "https://github.com/audreyr/cookiecutter/archive/${version}.tar.gz";
      sha256 = "1clxnabmc5s4b519r1sxyj1163x833ir8xcypmdfpf6r9kbb35vn";
    };

    buildInputs = with self; [ itsdangerous pytest freezegun docutils ];
    propagatedBuildInputs = with self; [
          jinja2 future binaryornot click whichcraft poyo jinja2_time ];

    meta = {
      homepage = https://github.com/audreyr/cookiecutter;
      description = "A command-line utility that creates projects from project templates";
      license = licenses.bsd3;
      maintainers = with maintainers; [ kragniz ];
    };
  };

  cookies = buildPythonPackage rec {
    name = "cookies-2.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/c/cookies/${name}.tar.gz";
      sha256 = "13pfndz8vbk4p2a44cfbjsypjarkrall71pgc97glk5fiiw9idnn";
    };

    doCheck = false;

    meta = {
      description = "Friendlier RFC 6265-compliant cookie parser/renderer";
      homepage = https://github.com/sashahart/cookies;
      license = licenses.mit;
    };
  };

  coveralls = callPackage ../development/python-modules/coveralls { };

  coverage = callPackage ../development/python-modules/coverage { };

  covCore = buildPythonPackage rec {
    name = "cov-core-1.15.0";
    src = pkgs.fetchurl {
      url = "mirror://pypi/c/cov-core/${name}.tar.gz";
      sha256 = "4a14c67d520fda9d42b0da6134638578caae1d374b9bb462d8de00587dba764c";
    };
    meta = {
      description = "Plugin core for use by pytest-cov, nose-cov and nose2-cov";
    };
    propagatedBuildInputs = with self; [ self.coverage ];
  };

  crcmod = buildPythonPackage rec {
    name = "crcmod-1.7";
    src = pkgs.fetchurl {
      url = mirror://pypi/c/crcmod/crcmod-1.7.tar.gz;
      sha256 = "07k0hgr42vw2j92cln3klxka81f33knd7459cn3d8aszvfh52w6w";
    };
    meta = {
      description = "Python module for generating objects that compute the Cyclic Redundancy Check (CRC)";
      homepage = http://crcmod.sourceforge.net/;
      license = licenses.mit;
    };
  };

  credstash = callPackage ../development/python-modules/credstash { };

  cython = callPackage ../development/python-modules/Cython { };

  cytoolz = callPackage ../development/python-modules/cytoolz { };

  cryptacular = buildPythonPackage rec {
    name = "cryptacular-1.4.1";

    buildInputs = with self; [ coverage nose ];
    propagatedBuildInputs = with self; [ pbkdf2 ];

    src = pkgs.fetchurl {
      url = "mirror://pypi/c/cryptacular/${name}.tar.gz";
      sha256 = "273f03d03f9b316671ae4f1c1c6b8d3c883da19a5706873e8f3d6543e13dd4a1";
    };

    # TODO: tests fail: TypeError: object of type 'NoneType' has no len()
    doCheck = false;

    meta = {
      maintainers = with maintainers; [ domenkozar ];
    };
  };

  cryptography = callPackage ../development/python-modules/cryptography { };

  cryptography_vectors = callPackage ../development/python-modules/cryptography_vectors { };

  curtsies = callPackage ../development/python-modules/curtsies { };

  jsonrpc-async = callPackage ../development/python-modules/jsonrpc-async { };

  jsonrpc-base = callPackage ../development/python-modules/jsonrpc-base { };

  jsonrpc-websocket = callPackage ../development/python-modules/jsonrpc-websocket { };

  onkyo-eiscp = callPackage ../development/python-modules/onkyo-eiscp { };

  pyunifi = callPackage ../development/python-modules/pyunifi { };

  tablib = callPackage ../development/python-modules/tablib { };

  py-wmi-client = callPackage ../development/python-modules/py-wmi-client { };

  wakeonlan = callPackage ../development/python-modules/wakeonlan { };

  openant = buildPythonPackage rec {
    name = "openant-unstable-2017-02-11";

    meta = with stdenv.lib; {
      homepage = "https://github.com/Tigge/openant";
      description = "ANT and ANT-FS Python Library";
      license = licenses.mit;
      platforms = platforms.linux;
    };

    src = pkgs.fetchFromGitHub {
      owner = "Tigge";
      repo = "openant";
      rev = "ed89281e37f65d768641e87356cef38877952397";
      sha256 = "1g81l9arqdy09ijswn3sp4d6i3z18d44lzyb78bwnvdb14q22k19";
    };

    # Removes some setup.py hacks intended to install udev rules.
    # We do the job ourselves in postInstall below.
    postPatch = ''
      sed -i -e '/cmdclass=.*/d' setup.py
    '';

    postInstall = ''
      install -dm755 "$out/etc/udev/rules.d"
      install -m644 resources/ant-usb-sticks.rules "$out/etc/udev/rules.d/99-ant-usb-sticks.rules"
    '';

    propagatedBuildInputs = with self; [ pyusb ];
  };

  opencv = toPythonModule (pkgs.opencv.override {
    enablePython = true;
    pythonPackages = self;
  });

  opencv3 = toPythonModule (pkgs.opencv3.override {
    enablePython = true;
    pythonPackages = self;
  });

  openidc-client = callPackage ../development/python-modules/openidc-client/default.nix {};


  idna = callPackage ../development/python-modules/idna { };

  mahotas = buildPythonPackage rec {
    name = "python-mahotas-${version}";
    version = "1.4.2";

    src = pkgs.fetchurl {
      url = "https://github.com/luispedro/mahotas/archive/v${version}.tar.gz";
      sha256 = "1mvsxh0pa5vdvbknlv1m68n7gw2cv4pyqgqp3r770rnmf6nxbp7m";
    };

    buildInputs = with self; [
      nose
      pillow
      scipy
    ];
    propagatedBuildInputs = with self; [
      numpy
      imread
    ];

    disabled = stdenv.isi686; # Failing tests

    meta = with stdenv.lib; {
      description = "Computer vision package based on numpy";
      homepage = http://mahotas.readthedocs.io/;
      maintainers = with maintainers; [ luispedro ];
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  MDP = callPackage ../development/python-modules/mdp {};

  minidb = buildPythonPackage rec {
    name = "minidb-2.0.1";

    src = pkgs.fetchurl {
      url = "https://thp.io/2010/minidb/${name}.tar.gz";
      sha256 = "1x958zr9jc26vaqij451qb9m2l7apcpz34ir9fwfjg4fwv24z2dy";
    };

    meta = {
      description = "A simple SQLite3-based store for Python objects";
      homepage = https://thp.io/2010/minidb/;
      license = stdenv.lib.licenses.isc;
      maintainers = [ stdenv.lib.maintainers.tv ];
    };
  };

  miniupnpc = callPackage ../development/python-modules/miniupnpc {};

  mixpanel = buildPythonPackage rec {
    version = "4.0.2";
    name = "mixpanel-${version}";
    disabled = isPy3k;

    src = pkgs.fetchzip {
      url = "https://github.com/mixpanel/mixpanel-python/archive/${version}.zip";
      sha256 = "0yq1bcsjzsz7yz4rp69izsdn47rvkld4wki2xmapp8gg2s9i8709";
    };

    buildInputs = with self; [ pytest mock ];
    propagatedBuildInputs = with self; [ six ];
    checkPhase = "py.test tests.py";

    meta = {
      homepage = https://github.com/mixpanel/mixpanel-python;
      description = "This is the official Mixpanel Python library. This library
                     allows for server-side integration of Mixpanel.";
      license = stdenv.lib.licenses.asl20;
    };
  };

  mpyq = callPackage ../development/python-modules/mpyq { };

  mxnet = buildPythonPackage rec {
    inherit (pkgs.mxnet) name version src meta;

    buildInputs = [ pkgs.mxnet ];
    propagatedBuildInputs = with self; [ requests numpy graphviz ];

    LD_LIBRARY_PATH = makeLibraryPath [ pkgs.mxnet ];

    doCheck = !isPy3k;

    preConfigure = ''
      cd python
    '';

    postInstall = ''
      rm -rf $out/mxnet
      ln -s ${pkgs.mxnet}/lib/libmxnet.so $out/${python.sitePackages}/mxnet
    '';
  };

  portpicker = callPackage ../development/python-modules/portpicker { };

  pkginfo = buildPythonPackage rec {
    version = "1.3.2";
    name = "pkginfo-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pkginfo/${name}.tar.gz";
      sha256 = "0qg4sq3m0pxvjahc3sncwhw42z5rfw22k0ybskmdqkl2agykay7q";
    };

    doCheck = false; # I don't know why, but with doCheck = true it fails.

    meta = {
      homepage = https://pypi.python.org/pypi/pkginfo;
      license = licenses.mit;
      description = "Query metadatdata from sdists / bdists / installed packages";

      longDescription = ''
        This package provides an API for querying the distutils metadata
        written in the PKG-INFO file inside a source distriubtion (an sdist)
        or a binary distribution (e.g., created by running bdist_egg). It can
        also query the EGG-INFO directory of an installed distribution, and the
        *.egg-info stored in a “development checkout” (e.g, created by running
        setup.py develop).
      '';
    };
  };

  pretend = buildPythonPackage rec {
    name = "pretend-1.0.8";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pretend/pretend-1.0.8.tar.gz";
      sha256 = "0r5r7ygz9m6d2bklflbl84cqhjkc2q12xgis8268ygjh30g2q3wk";
    };

    # No tests in archive
    doCheck = false;

    meta = {
      homepage = https://github.com/alex/pretend;
      license = licenses.bsd3;
    };
  };


  detox = self.buildPythonPackage rec {
    name = "detox-0.10.0";

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ tox py eventlet ];

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/detox/${name}.tar.gz";
      sha256 = "33b704c2a5657366850072fb2aa839df14dd2e692c0c1c2642c3ac30d5c0baec";
    };

    checkPhase = ''
      py.test
    '';

    # eventlet timeout, and broken invokation 3.5
    doCheck = false;

    meta = {
      description = "What is detox?";
      homepage = https://bitbucket.org/hpk42/detox;
    };
  };


  pbkdf2 = buildPythonPackage rec {
    name = "pbkdf2-1.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pbkdf2/${name}.tar.gz";
      sha256 = "ac6397369f128212c43064a2b4878038dab78dab41875364554aaf2a684e6979";
    };

    # ImportError: No module named test
    doCheck = false;

    meta = {
      maintainers = with maintainers; [ domenkozar ];
    };
  };

  bcrypt = callPackage ../development/python-modules/bcrypt { };

  cffi = callPackage ../development/python-modules/cffi { };

  pycollada = callPackage ../development/python-modules/pycollada { };

  pycontracts = buildPythonPackage rec {
    version = "1.7.9";
    name = "PyContracts-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/PyContracts/${name}.tar.gz";
      sha256 = "0rdc9pz08885vqkazjc3lyrrghmf3jzxnlsgpn8akl808x1qrfqf";
    };

    buildInputs = with self; [ nose ];

    propagatedBuildInputs = with self; [ pyparsing decorator six ];

    meta = {
      description = "Allows to declare constraints on function parameters and return values";
      homepage = https://pypi.python.org/pypi/PyContracts;
      license = licenses.lgpl2;
    };
  };

  pycparser = buildPythonPackage rec {
    name = "pycparser-${version}";
    version = "2.14";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pycparser/${name}.tar.gz";
      sha256 = "7959b4a74abdc27b312fed1c21e6caf9309ce0b29ea86b591fd2e99ecdf27f73";
    };

    checkPhase = ''
      ${python.interpreter} -m unittest discover -s tests
    '';

    meta = {
      description = "C parser in Python";
      homepage = https://github.com/eliben/pycparser;
      license = licenses.bsd3;
      maintainers = with maintainers; [ domenkozar ];
    };
  };

  pydub = callPackage ../development/python-modules/pydub {};

  pyjade = callPackage ../development/python-modules/pyjade {};

  PyLD = callPackage ../development/python-modules/PyLD { };

  python-jose = callPackage ../development/python-modules/python-jose {};

  pyhepmc = buildPythonPackage rec {
    name = "pyhepmc-${version}";
    version = "0.5.0";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyhepmc/${name}.tar.gz";
      sha256 = "1rbi8gqgclfvaibv9kzhfis11gw101x8amc93qf9y08ny4jfyr1d";
    };

    patches = [
      # merge PR https://bitbucket.org/andybuckley/pyhepmc/pull-requests/1/add-incoming-outgoing-generators-for/diff
      ../development/python-modules/pyhepmc_export_edges.patch
      # add bindings to Flow class
      ../development/python-modules/pyhepmc_export_flow.patch
    ];

    # regenerate python wrapper
    preConfigure = ''
      rm hepmc/hepmcwrap.py
      swig -c++ -I${pkgs.hepmc}/include -python hepmc/hepmcwrap.i
    '';

    buildInputs = with pkgs; [ swig hepmc ];

    HEPMCPATH = pkgs.hepmc;

    meta = {
      description = "A simple wrapper on the main classes of the HepMC event simulation representation, making it possible to create, read and manipulate HepMC events from Python code";
      license     = licenses.gpl2;
      maintainers = with maintainers; [ veprbl ];
      platforms   = platforms.all;
    };
  };

  pytest = self.pytest_34;

  pytest_34 = callPackage ../development/python-modules/pytest/default.nix{
    hypothesis = self.hypothesis.override {
      # hypothesis requires pytest that causes dependency cycle
      doCheck = false;
      pytest = null;
    };
  };

  # Needed for celery
  pytest_32 = self.pytest_34.overrideAttrs( oldAttrs: rec {
    version = "3.2.5";
    src = oldAttrs.src.override {
      inherit version;
      sha256 = "6d5bd4f7113b444c55a3bbb5c738a3dd80d43563d063fc42dcb0aaefbdd78b81";
    };
  });

  pytest-httpbin = callPackage ../development/python-modules/pytest-httpbin { };

  pytest-asyncio = callPackage ../development/python-modules/pytest-asyncio { };

  pytest-aiohttp = callPackage ../development/python-modules/pytest-aiohttp { };

  pytestcache = buildPythonPackage rec {
    name = "pytest-cache-1.0";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-cache/pytest-cache-1.0.tar.gz";
      sha256 = "1a873fihw4rhshc722j4h6j7g3nj7xpgsna9hhg3zn6ksknnhx5y";
    };

    buildInputs = with self; [ pytest];
    propagatedBuildInputs = with self ; [ execnet ];

    checkPhase = ''
      py.test
    '';

    # Too many failing tests. Are they maintained?
    doCheck = false;

    meta = {
      license = licenses.mit;
      homepage = "https://pypi.python.org/pypi/pytest-cache/";
      description = "pytest plugin with mechanisms for caching across test runs";
    };
  };

  pytest-catchlog = buildPythonPackage rec {
    name = "pytest-catchlog-1.2.2";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-catchlog/${name}.zip";
      sha256 = "1w7wxh27sbqwm4jgwrjr9c2gy384aca5jzw9c0wzhl0pmk2mvqab";
    };

    buildInputs = with self; [ pytest ];

    checkPhase = "make test";

    # Requires pytest < 3.1
    doCheck = false;

    meta = {
      license = licenses.mit;
      homepage = https://pypi.python.org/pypi/pytest-catchlog/;
      description = "py.test plugin to catch log messages. This is a fork of pytest-capturelog.";
    };
  };

  pytest-cram = callPackage ../development/python-modules/pytest-cram { };

  pytest-datafiles = callPackage ../development/python-modules/pytest-datafiles { };

  pytest-django = callPackage ../development/python-modules/pytest-django { };

  pytest-fixture-config = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "pytest-fixture-config";
    version = "1.0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/${pname}/${name}.tar.gz";
      sha256 = "7d7cc1cb25f88a707f083b1dc2e3c2fdfc6f37709567a2587dd0cd0bcd70edb6";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ coverage virtualenv pytestcov six ];

    checkPhase = ''
      py.test -k "not test_yield_requires_config_doesnt_skip and not test_yield_requires_config_skips"
    '';

    meta = {
      description = "Simple configuration objects for Py.test fixtures. Allows you to skip tests when their required config variables aren’t set.";
      homepage = https://github.com/manahl/pytest-plugins;
      license = licenses.mit;
      maintainers = with maintainers; [ ryansydnor ];
      platforms   = platforms.all;
    };
  };

  pytest-forked = callPackage ../development/python-modules/pytest-forked { };

  pytest-rerunfailures = callPackage ../development/python-modules/pytest-rerunfailures { };

  pytest-flake8 = callPackage ../development/python-modules/pytest-flake8 { };

  pytestflakes = buildPythonPackage rec {
    name = "pytest-flakes-${version}";
    version = "1.0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-flakes/${name}.tar.gz";
      sha256 = "9c2271654294020e134624020a2144cb93b7334809d70fb3f470cd31ec788a3a";
    };

    buildInputs = with self; [ pytestpep8 pytest ];
    propagatedBuildInputs = with self; [ pyflakes pytestcache ];

    checkPhase = ''
      py.test test_flakes.py
    '';

    meta = {
      license = licenses.mit;
      homepage = "https://pypi.python.org/pypi/pytest-flakes";
      description = "pytest plugin to check source code with pyflakes";
    };
  };

  pytest-mock = callPackage ../development/python-modules/pytest-mock { };

  pytest-timeout = callPackage ../development/python-modules/pytest-timeout { };

  pytest-warnings = callPackage ../development/python-modules/pytest-warnings { };

  pytestpep8 = buildPythonPackage rec {
    name = "pytest-pep8";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-pep8/pytest-pep8-1.0.6.tar.gz";
      sha256 = "06032agzhw1i9d9qlhfblnl3dw5hcyxhagn7b120zhrszbjzfbh3";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ pytestcache pep8 ];

    checkPhase = ''
      py.test
    '';

    # Fails
    doCheck = false;

    meta = {
      license = licenses.mit;
      homepage = "https://pypi.python.org/pypi/pytest-pep8";
      description = "pytest plugin to check PEP8 requirements";
    };
  };

  pytest-pep257 = callPackage ../development/python-modules/pytest-pep257 { };

  pytest-raisesregexp = buildPythonPackage rec {
    name = "pytest-raisesregexp-${version}";
    version = "2.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-raisesregexp/${name}.tar.gz";
      sha256 = "0fde8aac1a54f9b56e5f9c61fda76727542ed24968c27c6e3688c6f1885f1e61";
    };

    buildInputs = with self; [ py pytest ];

    # https://github.com/kissgyorgy/pytest-raisesregexp/pull/3
    prePatch = ''
      sed -i '3i\import io' setup.py
      substituteInPlace setup.py --replace "long_description=open('README.rst').read()," "long_description=io.open('README.rst', encoding='utf-8').read(),"
    '';

    meta = {
      description = "Simple pytest plugin to look for regex in Exceptions";
      homepage = https://github.com/Walkman/pytest_raisesregexp;
      license = with licenses; [ mit ];
    };
  };

  pytestrunner = callPackage ../development/python-modules/pytestrunner { };

  pytestquickcheck = callPackage ../development/python-modules/pytest-quickcheck { };

  pytest-server-fixtures = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "pytest-server-fixtures";
    version = "1.1.0";

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ setuptools-git pytest-shutil pytest-fixture-config psutil requests ];

    meta = {
      description = "Extensible server fixures for py.test";
      homepage    = "https://github.com/manahl/pytest-plugins";
      license     = licenses.mit;
      maintainers = with maintainers; [ nand0p ];
      platforms   = platforms.all;
    };

    doCheck = false;
    # RuntimeError: Unable to find a free server number to start Xvfb

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/${pname}/${name}.tar.gz";
      sha256 = "1gs9qimcn8q6xi9d6i5624l0dziwvn6nj2rda07fg15g1cq66s8l";
    };
  };

  pytest-shutil = buildPythonPackage rec {
    name = "pytest-shutil-${version}";
    version = "1.2.8";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-shutil/${name}.tar.gz";
      sha256 = "924accaec3f3781416139e580386ab4f849cb8662bc1072405a81d3a5e56bf3d";
    };
    buildInputs = with self; [ cmdline pytest ];
    propagatedBuildInputs = with self; [ pytestcov coverage setuptools-git mock pathpy execnet contextlib2 ];
    meta = {
      description = "A goodie-bag of unix shell and environment tools for py.test";
      homepage = https://github.com/manahl/pytest-plugins;
      maintainers = with maintainers; [ ryansydnor ];
      platforms   = platforms.all;
      license = licenses.mit;
    };

    checkPhase = ''
      py.test
    '';
  };

  pytestcov = buildPythonPackage rec {
    name = "pytest-cov-2.4.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-cov/${name}.tar.gz";
      sha256 = "03c2qc42r4bczyw93gd7n0qi1h1jfhw7fnbhi33c3vp1hs81gm2k";
    };

   buildInputs = with self; [ pytest pytest_xdist virtualenv process-tests ];
   propagatedBuildInputs = with self; [ coverage ];

   # xdist related tests fail with the following error
   # OSError: [Errno 13] Permission denied: 'py/_code'
   doCheck = false;
   checkPhase = ''
     # allow to find the module helper during the test run
     export PYTHONPATH=$PYTHONPATH:$PWD/tests
     py.test tests
   '';

    meta = {
      description = "Plugin for coverage reporting with support for both centralised and distributed testing, including subprocesses and multiprocessing";
      homepage = https://github.com/pytest-dev/pytest-cov;
      license = licenses.mit;
    };
  };

  pytest-expect = callPackage ../development/python-modules/pytest-expect { };

  pytest-virtualenv = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "pytest-virtualenv";
    version = "1.2.7";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/${pname}/${name}.tar.gz";
      sha256 = "51fb6468670624b2315aecaf1a2bbd698509e3ea6a1e28b094984c45e1376755";
    };
    buildInputs = with self; [ pytest pytestcov mock cmdline ];
    propagatedBuildInputs = with self; [ pytest-fixture-config pytest-shutil ];
    checkPhase = '' py.test tests/unit '';
    meta = {
      description = "Create a Python virtual environment in your test that cleans up on teardown. The fixture has utility methods to install packages and list what’s installed.";
      homepage = https://github.com/manahl/pytest-plugins;
      license = licenses.mit;
      maintainers = with maintainers; [ ryansydnor ];
      platforms   = platforms.all;
    };
  };

  pytest_xdist = callPackage ../development/python-modules/pytest-xdist { };

  pytest-localserver = callPackage ../development/python-modules/pytest-localserver { };

  pytest-subtesthack = buildPythonPackage rec {
    name = "pytest-subtesthack-${version}";
    version = "0.1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pytest-subtesthack/${name}.tar.gz";
      sha256 = "15kzcr5pchf3id4ikdvlv752rc0j4d912n589l4rifp8qsj19l1x";
    };

    buildInputs = with self; [ pytest ];

    # no upstream test
    doCheck = false;

    meta = {
      description = "Terrible plugin to set up and tear down fixtures within the test function itself";
      homepage = https://github.com/untitaker/pytest-subtesthack;
      license = licenses.publicDomain;
    };
  };

  pytest-sugar = callPackage ../development/python-modules/pytest-sugar { };

  tinycss = buildPythonPackage rec {
    name = "tinycss-${version}";
    version = "0.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/t/tinycss/${name}.tar.gz";
      sha256 = "1pichqra4wk86142hqgvy9s5x6c5k5zhy8l9qxr0620pqk8spbd4";
    };

    buildInputs = with self; [ pytest ];

    propagatedBuildInputs = with self; [ cssutils ];

    checkPhase = ''
      py.test $out/${python.sitePackages}
    '';

    # Disable Cython tests for PyPy
    TINYCSS_SKIP_SPEEDUPS_TESTS = optional isPyPy true;

    meta = {
      description = "Complete yet simple CSS parser for Python";
      license = licenses.bsd3;
      homepage = http://pythonhosted.org/tinycss/;
    };
  };


  cssselect = buildPythonPackage rec {
    name = "cssselect-${version}";
    version = "0.9.1";
    src = pkgs.fetchurl {
      url = "mirror://pypi/c/cssselect/${name}.tar.gz";
      sha256 = "10h623qnp6dp1191jri7lvgmnd4yfkl36k9smqklp1qlf3iafd85";
    };
    # AttributeError: 'module' object has no attribute 'tests'
    doCheck = false;
  };

  cssutils = buildPythonPackage (rec {
    name = "cssutils-1.0.1";

    src = pkgs.fetchurl {
      url = mirror://pypi/c/cssutils/cssutils-1.0.1.tar.gz;
      sha256 = "0qwha9x1wml2qmipbcz03gndnlwhzrjdvw9i09si247a90l8p8fq";
    };

    buildInputs = with self; [ self.mock ];

    # couple of failing tests
    doCheck = false;

    meta = {
      description = "A Python package to parse and build CSS";

      homepage = http://code.google.com/p/cssutils/;

      license = licenses.lgpl3Plus;
    };
  });

  darcsver = buildPythonPackage (rec {
    name = "darcsver-1.7.4";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/darcsver/${name}.tar.gz";
      sha256 = "1yb1c3jxqvy4r3qiwvnb86qi5plw6018h15r3yk5ji3nk54qdcb6";
    };

    buildInputs = with self; [ self.mock ];

    # Note: We don't actually need to provide Darcs as a build input.
    # Darcsver will DTRT when Darcs isn't available.  See news.gmane.org
    # http://thread.gmane.org/gmane.comp.file-systems.tahoe.devel/3200 for a
    # discussion.

    # AttributeError: 'module' object has no attribute 'test_darcsver'
    doCheck = false;

    meta = {
      description = "Darcsver, generate a version number from Darcs history";

      homepage = https://pypi.python.org/pypi/darcsver;

      license = "BSD-style";
    };
  });

  dask = callPackage ../development/python-modules/dask { };

  datrie = buildPythonPackage rec {
    name = "datrie";
    version = "0.7.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/datrie/datrie-${version}.tar.gz";
      sha256 = "08r0if7dry2q7p34gf7ffyrlnf4bdvnprxgydlfxgfnvq8f3f4bs";
    };

    buildInputs = with self; [ pytest pytestrunner hypothesis ];
    meta = {
      description = "Super-fast, efficiently stored Trie for Python";
      homepage = "https://github.com/kmike/datrie";
      license = licenses.lgpl2;
      maintainers = with maintainers; [ lewo ];
    };
  };

  heapdict = buildPythonPackage rec {
    name = "HeapDict-${version}";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/H/HeapDict/${name}.tar.gz";
      sha256 = "0nhvxyjq6fp6zd7jzmk5x4fg6xhakqx9lhkp5yadzkqn0rlf7ja0";
    };
    doCheck = !isPy3k;
    meta = {
      description = "a heap with decrease-key and increase-key operations.";
      homepage = http://stutzbachenterprises.com;
      license = licenses.bsd3;
      maintainers = with maintainers; [ teh ];
    };
  };

  zict = buildPythonPackage rec {

    name = "zict-${version}";
    version = "0.1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/z/zict/${name}.tar.gz";
      sha256 = "12h95vbkbar1hc6cr1kpr6zr486grj3mpx4lznvmnai0iy6pbqp4";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ heapdict ];

    meta = {
      description = "Mutable mapping tools.";
      homepage = https://github.com/dask/zict;
      license = licenses.bsd3;
      maintainers = with maintainers; [ teh ];
    };
  };

  distributed = buildPythonPackage rec {

    name = "distributed-${version}";
    version = "1.15.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/distributed/${name}.tar.gz";
      sha256 = "037a07sdf2ch1d360nqwqz3b4ld8msydng7mw4i5s902v7xr05l6";
    };

    buildInputs = with self; [ pytest docutils ];
    propagatedBuildInputs = with self; [
      dask six boto3 s3fs tblib locket msgpack-python click cloudpickle tornado
      psutil botocore zict lz4 sortedcollections sortedcontainers
    ] ++ (if !isPy3k then [ singledispatch ] else []);

    # py.test not picking up local config file, even when running
    # manually: E ValueError: no option named '--runslow'
    doCheck = false;

    meta = {
      description = "Distributed computation in Python.";
      homepage = "http://distributed.readthedocs.io/en/latest/";
      license = licenses.bsd3;
      maintainers = with maintainers; [ teh ];
    };
  };

  digital-ocean = buildPythonPackage rec {
    name = "python-digitalocean-1.10.1";

    propagatedBuildInputs = with self; [ requests ];

    # Package doesn't distribute tests.
    doCheck = false;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-digitalocean/${name}.tar.gz";
      sha256 = "12qybflfnl08acspz7rpaprmlabgrzimacbd7gm9qs5537hl3qnp";
    };

    meta = {
      description = "digitalocean.com API to manage Droplets and Images";
      homepage = https://pypi.python.org/pypi/python-digitalocean;
      license = licenses.lgpl3;
      maintainers = with maintainers; [ teh ];
    };
  };

  leather = callPackage ../development/python-modules/leather { };

  libais = callPackage ../development/python-modules/libais { };

  libtmux = callPackage ../development/python-modules/libtmux { };

  libusb1 = callPackage ../development/python-modules/libusb1 { inherit (pkgs) libusb1; };

  linuxfd = callPackage ../development/python-modules/linuxfd { };

  locket = buildPythonPackage rec {
    name = "locket-${version}";
    version = "0.2.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/locket/${name}.tar.gz";
      sha256 = "1d4z2zngrpqkrfhnd4yhysh66kjn4mblys2l06sh5dix2p0n7vhz";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [  ];

    # weird test requirements (spur.local>=0.3.7,<0.4)
    doCheck = false;

    meta = {
      description = "Locket implements a lock that can be used by multiple processes provided they use the same path.";
      homepage = "https://github.com/mwilliamson/locket.py";
      license = licenses.bsd2;
      maintainers = with maintainers; [ teh ];
    };
  };

  tblib = buildPythonPackage rec {
    name = "tblib-${version}";
    version = "1.3.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/t/tblib/${name}.tar.gz";
      sha256 = "02iahfkfa927hb4jq2bak36ldihwapzacfiq5lyxg8llwn98a1yi";
    };

    meta = {
      description = "Traceback fiddling library. Allows you to pickle tracebacks.";
      homepage = "https://github.com/ionelmc/python-tblib";
      license = licenses.bsd2;
      maintainers = with maintainers; [ teh ];
    };
  };

  s3fs = buildPythonPackage rec {
    name = "s3fs-${version}";
    version = "0.0.8";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/s3fs/${name}.tar.gz";
      sha256 = "0zbdzqrim0zig94fk1hswg4vfdjplw6jpx3pdi42qc830h0nscn8";
    };

    buildInputs = with self; [ docutils ];
    propagatedBuildInputs = with self; [ boto3 ];

    # Depends on `moto` which has a long dependency chain with exact
    # version requirements that can't be made to work with current
    # pythonPackages.
    doCheck = false;

    meta = {
      description = "S3FS builds on boto3 to provide a convenient Python filesystem interface for S3.";
      homepage = "http://github.com/dask/s3fs/";
      license = licenses.bsd3;
      maintainers = with maintainers; [ teh ];
    };
  };

  datashape = callPackage ../development/python-modules/datashape { };

  requests-cache = buildPythonPackage (rec {
    name = "requests-cache-${version}";
    version = "0.4.13";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/requests-cache/${name}.tar.gz";
      sha256 = "18jpyivnq5pjbkymk3i473rihpj2bgikafpha7xvr6w736hiqmpy";
    };

    buildInputs = with self; [ mock ];

    propagatedBuildInputs = with self; [ requests six urllib3 ];

    meta = {
      description = "Persistent cache for requests library";
      homepage = https://pypi.python.org/pypi/requests-cache;
      license = licenses.bsd3;
    };
  });

  requests-unixsocket = callPackage ../development/python-modules/requests-unixsocket {};

  howdoi = buildPythonPackage (rec {
    name = "howdoi-${version}";
    version = "1.1.7";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/howdoi/${name}.tar.gz";
      sha256 = "df4e49a219872324875d588e7699a1a82174a267e8487505e86bfcb180aea9b7";
    };

    propagatedBuildInputs = with self; [ self.six requests-cache pygments pyquery ];

    meta = {
      description = "Instant coding answers via the command line";
      homepage = https://pypi.python.org/pypi/howdoi;
      license = licenses.mit;
    };
  });

  neurotools = buildPythonPackage (rec {
    name = "NeuroTools-${version}";
    version = "0.3.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/N/NeuroTools/${name}.tar.gz";
      sha256 = "0ly6qa87l3afhksab06vp1iimlbm1kdnsw98mxcnpzz9q07l4nd4";
    };

    disabled = isPy3k;

    # Tests are not automatically run
    # Many tests fail (using py.test), and some need R
    doCheck = false;

    propagatedBuildInputs = with self; [
      scipy
      numpy
      matplotlib
      tables
      pyaml
      urllib3
      rpy2
      mpi4py
    ];

    meta = {
      description = "Collection of tools to support analysis of neural activity";
      homepage = https://pypi.python.org/pypi/NeuroTools;
      license = licenses.gpl2;
      maintainers = with maintainers; [ nico202 ];
    };
  });

  jdatetime = buildPythonPackage (rec {
    name = "jdatetime-${version}";
    version = "1.7.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jdatetime/${name}.tar.gz";
      sha256 = "c08ba5791c2350b26e87ddf478bf223108146e241b6c949538221b54afd633ac";
    };

    propagatedBuildInputs = with self; [ self.six ];

    meta = {
      description = "Jalali datetime binding for python";
      homepage = https://pypi.python.org/pypi/jdatetime;
      license = licenses.psfl;
    };
  });

  daphne = callPackage ../development/python-modules/daphne { };

  dateparser = callPackage ../development/python-modules/dateparser { };

  # Actual name of package
  python-dateutil = callPackage ../development/python-modules/dateutil { };
  # Alias that we should deprecate
  dateutil = self.python-dateutil;

  # Buildbot 0.8.7p1 needs dateutil==1.5
  dateutil_1_5 = buildPythonPackage (rec {
    name = "dateutil-1.5";

    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-dateutil/python-${name}.tar.gz";
      sha256 = "02dhw57jf5kjcp7ng1if7vdrbnlpb9yjmz7wygwwvf3gni4766bg";
    };

    propagatedBuildInputs = with self; [ self.six ];

    meta = {
      description = "Powerful extensions to the standard datetime module";
      homepage = https://pypi.python.org/pypi/python-dateutil;
      license = "BSD-style";
    };
  });

  decorator = callPackage ../development/python-modules/decorator { };

  deform = buildPythonPackage rec {
    name = "deform-2.0a2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/deform/${name}.tar.gz";
      sha256 = "3fa4d287c8da77a83556e4a5686de006ddd69da359272120b915dc8f5a70cabd";
    };

    buildInputs = with self; [] ++ optional isPy26 unittest2;

    propagatedBuildInputs =
      [ self.beautifulsoup4
        self.peppercorn
        self.colander
        self.translationstring
        self.chameleon
        self.zope_deprecation
        self.coverage
        self.nose
      ];

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };

  demjson = callPackage ../development/python-modules/demjson { };

  derpconf = self.buildPythonPackage rec {
    name = "derpconf-0.4.9";

    propagatedBuildInputs = with self; [ six ];

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/derpconf/${name}.tar.gz";
      sha256 = "9129419e3a6477fe6366c339d2df8c614bdde82a639f33f2f40d4de9a1ed236a";
    };

    meta = {
      description = "derpconf abstracts loading configuration files for your app";
      homepage = https://github.com/globocom/derpconf;
      license = licenses.mit;
    };
  };

  deskcon = self.buildPythonPackage rec {
    name = "deskcon-0.3";
    disabled = !isPy27;

    src = pkgs.fetchFromGitHub {
      owner= "screenfreeze";
      repo = "deskcon-desktop";
      rev = "267804122188fa79c37f2b21f54fe05c898610e6";
      sha256 ="0i1dd85ls6n14m9q7lkympms1w3x0pqyaxvalq82s4xnjdv585j3";
    };

    phases = [ "unpackPhase" "installPhase" ];

    pythonPath = [ self.pyopenssl pkgs.gtk3 ];

    installPhase = ''
      substituteInPlace server/deskcon-server --replace "python2" "python"

      mkdir -p $out/bin
      mkdir -p $out/lib/${python.libPrefix}/site-packages
      cp -r "server/"* $out/lib/${python.libPrefix}/site-packages
      mv $out/lib/${python.libPrefix}/site-packages/deskcon-server $out/bin/deskcon-server

      wrapPythonProgramsIn $out/bin "$out $pythonPath"
    '';

    meta = {
      description = "Integrates an Android device into a desktop";
      homepage = https://github.com/screenfreeze/deskcon-desktop;
      license = licenses.gpl3;
    };
  };


  dill = callPackage ../development/python-modules/dill { };

  discogs_client = callPackage ../development/python-modules/discogs_client { };

  dmenu-python = callPackage ../development/python-modules/dmenu { };

  dnspython = callPackage ../development/python-modules/dnspython { };
  dns = self.dnspython; # Alias for compatibility, 2017-12-10

  docker = callPackage ../development/python-modules/docker {};

  dockerpty = buildPythonPackage rec {
    name = "dockerpty-0.4.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/dockerpty/${name}.tar.gz";
      sha256 = "1kjn64wx23jmr8dcc6g7bwlmrhfmxr77gh6iphqsl39sayfxdab9";
    };

    propagatedBuildInputs = with self; [ six ];

    meta = {
      description = "Functionality needed to operate the pseudo-tty (PTY) allocated to a docker container";
      homepage = https://github.com/d11wtq/dockerpty;
      license = licenses.asl20;
    };
  };

  docker_pycreds = buildPythonPackage rec {
    name = "docker-pycreds-${version}";
    version = "0.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/docker-pycreds/${name}.tar.gz";
      sha256 = "0j3k5wk3bww5y0f2rvgzsin0q98k0i9j308vpsmxidw0y8n3m0wk";
    };

    doCheck = false; # require docker-credential-helpers binaries

    propagatedBuildInputs = with self; [
      six
    ];

    meta = {
      description = "Python bindings for the docker credentials store API.";
      homepage = https://github.com/shin-/dockerpy-creds;
      license = licenses.asl20;
    };
  };

  docker_registry_core = buildPythonPackage rec {
    name = "docker-registry-core-2.0.3";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/docker-registry-core/${name}.tar.gz";
      sha256 = "347e804f1f35b28dbe27bf8d7a0b630fca29d684032139bf26e3940572360360";
    };

    DEPS = "loose";

    doCheck = false;
    propagatedBuildInputs = with self; [
      boto redis setuptools simplejson
    ];

    patchPhase = "> requirements/main.txt";

    meta = {
      description = "Docker registry core package";
      homepage = https://github.com/docker/docker-registry;
      license = licenses.asl20;
    };
  };

  docker_registry = buildPythonPackage rec {
    name = "docker-registry-0.9.1";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/docker-registry/${name}.tar.gz";
      sha256 = "1svm1h59sg4bwj5cy10m016gj0xpiin15nrz5z66h47sbkndvlw3";
    };

    DEPS = "loose";

    doCheck = false; # requires redis server
    propagatedBuildInputs = with self; [
      setuptools docker_registry_core blinker flask gevent gunicorn pyyaml
      requests rsa sqlalchemy setuptools backports_lzma m2crypto
    ];

    patchPhase = "> requirements/main.txt";

    # Default config uses needed env variables
    postInstall = ''
      ln -s $out/lib/python2.7/site-packages/config/config_sample.yml $out/lib/python2.7/site-packages/config/config.yml
    '';

    meta = {
      description = "Docker registry core package";
      homepage = https://github.com/docker/docker-registry;
      license = licenses.asl20;
    };
  };

  docopt = buildPythonPackage rec {
    name = "docopt-0.6.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/docopt/${name}.tar.gz";
      sha256 = "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491";
    };

    meta = {
      description = "Pythonic argument parser, that will make you smile";
      homepage = http://docopt.org/;
      license = licenses.mit;
    };
  };

  doctest-ignore-unicode = buildPythonPackage rec {
    name = "doctest-ignore-unicode-${version}";
    version = "0.1.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/doctest-ignore-unicode/${name}.tar.gz";
      sha256= "fc90b2d0846477285c6b67fc4cb4d6f39fcf76d8752f4df0a241486f31512ad5";
    };

    propagatedBuildInputs = with self; [ nose ];

    meta = {
      description = "Add flag to ignore unicode literal prefixes in doctests";
      license = with licenses; [ asl20 ];
      homepage = https://github.com/gnublade/doctest-ignore-unicode;
    };
  };

  dogpile_cache = callPackage ../development/python-modules/dogpile.cache { };

  dogpile_core = buildPythonPackage rec {
    name = "dogpile.core-0.4.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/dogpile.core/dogpile.core-0.4.1.tar.gz";
      sha256 = "be652fb11a8eaf66f7e5c94d418d2eaa60a2fe81dae500f3743a863cc9dbed76";
    };

    doCheck = false;

    meta = {
      description = "A 'dogpile' lock, typically used as a component of a larger caching solution";
      homepage = https://bitbucket.org/zzzeek/dogpile.core;
      license = licenses.bsd3;
    };
  };

  dopy = buildPythonPackage rec {
    version = "2016-01-04";
    name = "dopy-${version}";

    src = pkgs.fetchFromGitHub {
      owner = "Wiredcraft";
      repo = "dopy";
      rev = "cb443214166a4e91b17c925f40009ac883336dc3";
      sha256 ="0ams289qcgna96aak96jbz6wybs6qb95h2gn8lb4lmx2p5sq4q56";
    };

    propagatedBuildInputs = with self; [ requests six ];

    meta = {
      description = "Digital Ocean API python wrapper";
      homepage = "https://github.com/Wiredcraft/dopy";
      license = licenses.mit;
      maintainers = with maintainers; [ lihop ];
      platforms = platforms.all;
    };
  };

  dpkt = callPackage ../development/python-modules/dpkt {};

  urllib3 = callPackage ../development/python-modules/urllib3 {};

  dropbox = buildPythonPackage rec {
    name = "dropbox-${version}";
    version = "8.0.0";
    doCheck = false; # Set DROPBOX_TOKEN environment variable to a valid token.

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/dropbox/${name}.tar.gz";
      sha256 = "0bixx80zjq0286dwm4zhg8bdhc8pqlrqy4n2jg7i6m6a4gv4gak5";
    };

    buildInputs = with self; [ pytestrunner ];
    propagatedBuildInputs = with self; [ requests urllib3 mock setuptools ];

    meta = {
      description = "A Python library for Dropbox's HTTP-based Core and Datastore APIs";
      homepage = https://www.dropbox.com/developers/core/docs;
      license = licenses.mit;
    };
  };

  ds4drv = callPackage ../development/python-modules/ds4drv {
    inherit (pkgs) fetchFromGitHub bluez;
  };

  dyn = callPackage ../development/python-modules/dyn { };

  easydict = callPackage ../development/python-modules/easydict { };

  EasyProcess = buildPythonPackage rec {
    name = "EasyProcess-0.2.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/E/EasyProcess/${name}.tar.gz";
      sha256 = "94e241cadc9a46f55b5c06000df85618849602e7e1865b8de87576b90a22e61f";
    };

    # No tests
    doCheck = false;

    meta = {
      description = "Easy to use python subprocess interface";
      homepage = "https://github.com/ponty/EasyProcess";
      license = licenses.bsdOriginal;
      maintainers = with maintainers; [ layus ];
    };
  };

  easy-thumbnails = callPackage ../development/python-modules/easy-thumbnails { };

  eccodes = disabledIf (!isPy27)
    (toPythonModule (pkgs.eccodes.override {
      enablePython = true;
      pythonPackages = self;
    }));

  EditorConfig = buildPythonPackage rec {
    name = "EditorConfig-${version}";
    version = "0.12.0";

    # fetchgit used to ensure test submodule is available
    src = pkgs.fetchgit {
      url = "https://github.com/editorconfig/editorconfig-core-py";
      rev = "refs/tags/v${version}";
      sha256 = "0svk7id7ncygj2rnxhm7602xizljyidk4xgrl6i0xgq3829cz4bl";
    };

    buildInputs = [ pkgs.cmake ];
    checkPhase = ''
      cmake .
      # utf_8_char fails with python3
      ctest -E "utf_8_char" .
    '';

    meta = {
      homepage = "http://editorconfig.org";
      description = "EditorConfig File Locator and Interpreter for Python";
      license = stdenv.lib.licenses.psfl;
    };
  };

  edward = callPackage ../development/python-modules/edward { };

  elasticsearch = callPackage ../development/python-modules/elasticsearch { };

  elasticsearchdsl = buildPythonPackage (rec {
    name = "elasticsearch-dsl-0.0.9";

    src = pkgs.fetchurl {
      url = "mirror://pypi/e/elasticsearch-dsl/${name}.tar.gz";
      sha256 = "1gdcdshk881vy18p0czcmbb3i4s5hl8llnfg6961b6x7jkvhihbj";
    };

    buildInputs = with self; [ covCore dateutil elasticsearch mock pytest pytestcov unittest2 urllib3 pytz ];

    # ImportError: No module named test_elasticsearch_dsl
    # Tests require a local instance of elasticsearch
    doCheck = false;

    meta = {
      description = "Python client for Elasticsearch";
      homepage = https://github.com/elasticsearch/elasticsearch-dsl-py;
      license = licenses.asl20;
      maintainers = with maintainers; [ desiderius ];
    };
  });

  elasticsearch-curator = callPackage ../development/python-modules/elasticsearch-curator { };

  entrypoints = callPackage ../development/python-modules/entrypoints { };

  enzyme = callPackage ../development/python-modules/enzyme {};

  escapism = buildPythonPackage rec {
    name = "escapism-${version}";
    version = "0.0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/e/escapism/${name}.tar.gz";
      sha256 = "1yfyxwxb864xrmrrqgp85xgsh4yrrq5mmzvkdg19jwr7rm6sqx9p";
    };

    # No tests distributed
    doCheck = false;

    meta = {
      description = "Simple, generic API for escaping strings";
      homepage = "https://github.com/minrk/escapism";
      license = licenses.mit;
      maintainers = with maintainers; [ bzizou ];
    };
  };

  etcd = buildPythonPackage rec {
    name = "etcd-${version}";
    version = "2.0.8";

    # PyPI package is incomplete
    src = pkgs.fetchurl {
      url = "https://github.com/dsoprea/PythonEtcdClient/archive/${version}.tar.gz";
      sha256 = "0fi6rxa1yxvz7nwrc7dw6fax3041d6bj3iyhywjgbkg7nadi9i8v";
    };

    patchPhase = ''
      sed -i -e '13,14d;37d' setup.py
    '';

    propagatedBuildInputs = with self; [ simplejson pytz requests ];

    # No proper tests are available
    doCheck = false;

    meta = {
      description = "A Python etcd client that just works";
      homepage = https://github.com/dsoprea/PythonEtcdClient;
      license = licenses.gpl2;
    };
  };

  evdev = callPackage ../development/python-modules/evdev {};

  eve = callPackage ../development/python-modules/eve {};

  eventlib = buildPythonPackage rec {
    pname = "python-eventlib";
    name = "${pname}-${version}";
    version = "0.2.2";

    # Judging from SyntaxError
    disabled = isPy3k;

    src = pkgs.fetchdarcs {
      url = "http://devel.ag-projects.com/repositories/${pname}";
      rev = "release-${version}";
      sha256 = "1zxhpq8i4jwsk7wmfncqfm211hqikj3hp38cfv509924bi76wak8";
    };

    propagatedBuildInputs = with self; [ greenlet ];

    doCheck = false;

    meta = {
      description = "Eventlib bindings for python";
      homepage    = "http://ag-projects.com/";
      license     = licenses.lgpl2;
      platforms   = platforms.all;
    };
  };

  events = buildPythonPackage rec {
    name = "Events-${version}";
    version = "0.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/E/Events/${name}.tar.gz";
      sha256 = "0rymyfvarjdi2fdhfz2iqmp4wgd2n2sm0p2mx44c3spm7ylnqzqa";
    };

    meta = {
      homepage = "http://events.readthedocs.org";
      description = "Bringing the elegance of C# EventHanlder to Python";
      license = licenses.bsd3;
    };
  };


  eyeD3 = buildPythonPackage rec {
    version = "0.7.8";
    name    = "eyeD3-${version}";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "http://eyed3.nicfit.net/releases/${name}.tar.gz";
      sha256 = "1nv7nhfn1d0qm7rgkzksbccgqisng8klf97np0nwaqwd5dbmdf86";
    };

    buildInputs = with self; [ paver ];

    postInstall = ''
      for prog in "$out/bin/"*; do
        wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH" \
                            --prefix PATH : ${python}/bin
      done
    '';

    meta = {
      description = "A Python module and command line program for processing ID3 tags";
      homepage    = http://eyed3.nicfit.net/;
      license     = licenses.gpl2;
      maintainers = with maintainers; [ lovek323 ];
      platforms   = platforms.unix;

      longDescription = ''
        eyeD3 is a Python module and command line program for processing ID3
        tags. Information about mp3 files (i.e bit rate, sample frequency, play
        time, etc.) is also provided. The formats supported are ID3 v1.0/v1.1
        and v2.3/v2.4.
      '';
    };
  };

  execnet = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "execnet";
    version = "1.4.1";
    src = pkgs.fetchurl {
      url = "mirror://pypi/e/${pname}/${name}.tar.gz";
      sha256 = "1rpk1vyclhg911p3hql0m0nrpq7q7mysxnaaw6vs29cpa6kx8vgn";
    };
    buildInputs = with self; [ pytest setuptools_scm ];
    propagatedBuildInputs = with self; [ apipkg ];
    # remove vbox tests
    postPatch = ''
      rm -v testing/test_termination.py
      rm -v testing/test_channel.py
      rm -v testing/test_xspec.py
      rm -v testing/test_gateway.py
    '';
    checkPhase = ''
      py.test testing
    '';
    __darwinAllowLocalNetworking = true;
    meta = {
      description = "Rapid multi-Python deployment";
      license = licenses.gpl2;
      homepage = "http://codespeak.net/execnet";
      maintainers = with maintainers; [ nand0p ];
    };
  };

  ezdxf = callPackage ../development/python-modules/ezdxf {};

  facebook-sdk = buildPythonPackage rec {
    name = "facebook-sdk-0.4.0";

    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/facebook-sdk/facebook-sdk-0.4.0.tar.gz";
      sha256 = "5a96c54d06213039dff1fe1fabc51972e394666cd6d83ea70f7c2e67472d9b72";
    };

    meta = with pkgs.stdenv.lib; {
      description = "Client library that supports the Facebook Graph API and the official Facebook JavaScript SDK";
      homepage = https://github.com/pythonforfacebook/facebook-sdk;
      license = licenses.asl20 ;
    };
  };

  faker = callPackage ../development/python-modules/faker { };

  fake_factory = buildPythonPackage rec {
    name = "fake-factory-${version}";
    version = "0.6.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/fake-factory/${name}.tar.gz";
      sha256 = "09sgk0kylsshs64a1xsz3qr187sbnqrbf4z8k3dgsy32lsgyffv2";
    };

    propagatedBuildInputs = with self; [ six dateutil ipaddress mock ];
    checkPhase = ''
      ${python.interpreter} -m unittest faker.tests
    '';

    meta = {
      description = "A Python package that generates fake data for you";
      homepage    = https://pypi.python.org/pypi/fake-factory;
      license     = licenses.mit;
      maintainers = with maintainers; [ lovek323 ];
      platforms   = platforms.unix;
    };
  };

  factory_boy = buildPythonPackage rec {
    name = "factory_boy-${version}";
    version = "2.6.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/factory_boy/${name}.tar.gz";
      sha256 = "0a21f8kq917fj8xgmyp6gy8vcrlzzgwn80qas0d76h3vjbdy0bdq";
    };

    propagatedBuildInputs = with self; [ fake_factory ];

    meta = {
      description = "A Python package to create factories for complex objects";
      homepage    = https://github.com/rbarrois/factory_boy;
      license     = licenses.mit;
    };
  };

  Fabric = buildPythonPackage rec {
    name = "Fabric-${version}";
    version = "1.13.2";
    src = pkgs.fetchurl {
      url = "mirror://pypi/F/Fabric/${name}.tar.gz";
      sha256 = "0k944dxr41whw7ib6380q9x15wyskx7fqni656icdn8rzshn9bwq";
    };
    disabled = isPy3k;
    doCheck = (!isPyPy);  # https://github.com/fabric/fabric/issues/11891
    propagatedBuildInputs = with self; [ paramiko pycrypto ];
    buildInputs = with self; [ fudge_9 nose ];
  };

  faulthandler = if ! isPy3k
    then callPackage ../development/python-modules/faulthandler {}
    else throw "faulthandler is built into ${python.executable}";

  fedpkg = callPackage ../development/python-modules/fedpkg { };

  flit = callPackage ../development/python-modules/flit { };

  Flootty = buildPythonPackage rec {
    name = "Flootty-3.2.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/F/Flootty/${name}.tar.gz";
      sha256 = "14n2q2k388xbmp5rda5ss879bg5cbibk4zzz7c8mrjsmxhgagmmg";
    };

    meta = with pkgs.stdenv.lib; {
      description = "Floobits collaborative terminal";
      homepage = "https://github.com/Floobits/flootty/";
      maintainers = with maintainers; [ garbas ];
      license = licenses.asl20;
    };
  };

  flowlogs_reader = buildPythonPackage rec {
    name = "flowlogs_reader-1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/flowlogs_reader/${name}.tar.gz";
      sha256 = "0158aki6m3pkf98hpd60088qyhrfxkmybdf8hv3qfl8nb61vaiwf";
    };

    propagatedBuildInputs = with self; [
      botocore boto3 docutils
    ];
    buildInputs = with self; [
      unittest2 mock
    ];

    meta = with pkgs.stdenv.lib; {
      description = "Python library to make retrieving Amazon VPC Flow Logs from CloudWatch Logs a bit easier";
      homepage = "https://github.com/obsrvbl/flowlogs-reader";
      maintainers = with maintainers; [ cransom ];
      license = licenses.asl20;
    };
  };

  fpdf = callPackage ../development/python-modules/fpdf { };

  fritzconnection = callPackage ../development/python-modules/fritzconnection { };

  frozendict = buildPythonPackage rec {
    name = "frozendict-0.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/frozendict/${name}.tar.gz";
      sha256 = "0m4kg6hbadvf99if78nx01q7qnbyhdw3x4znl5dasgciyi54432n";
    };

    meta = {
      homepage = https://github.com/slezica/python-frozendict;
      description = "An immutable dictionary";
      license = stdenv.lib.licenses.mit;
    };
  };

  ftputil = callPackage ../development/python-modules/ftputil { };

  fudge = buildPythonPackage rec {
    name = "fudge-1.1.0";
    src = pkgs.fetchurl {
      url = "mirror://pypi/f/fudge/${name}.tar.gz";
      sha256 = "eba59a926fa1df1ab6dddd69a7a8af21865b16cad800cb4d1af75070b0f52afb";
    };
    buildInputs = with self; [ nose nosejs ];
    propagatedBuildInputs = with self; [ sphinx ];

    disabled = isPy3k;

    checkPhase = ''
      nosetests -v
    '';
  };

  fudge_9 = self.fudge.override rec {
    name = "fudge-0.9.6";
    src = pkgs.fetchurl {
      url = "mirror://pypi/f/fudge/${name}.tar.gz";
      sha256 = "34690c4692e8717f4d6a2ab7d841070c93c8d0ea0d2615b47064e291f750b1a0";
    };
  };


  funcparserlib = buildPythonPackage rec {
    name = "funcparserlib-0.3.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/funcparserlib/${name}.tar.gz";
      sha256 = "b7992eac1a3eb97b3d91faa342bfda0729e990bd8a43774c1592c091e563c91d";
    };

    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';

    # Tests are Python 2.x only judging from SyntaxError
    doCheck = !(isPy3k);

    meta = {
      description = "Recursive descent parsing library based on functional combinators";
      homepage = https://code.google.com/p/funcparserlib/;
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };

  singledispatch = buildPythonPackage rec {
    name = "singledispatch-3.4.0.3";

    propagatedBuildInputs = with self; [ six ];

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/singledispatch/${name}.tar.gz";
      sha256 = "5b06af87df13818d14f08a028e42f566640aef80805c3b50c5056b086e3c2b9c";
    };

    meta = {
      homepage = http://docs.python.org/3/library/functools.html;
    };
  };

  functools32 = if isPy3k then null else buildPythonPackage rec {
    name = "functools32-${version}";
    version = "3.2.3-2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/functools32/functools32-${version}.tar.gz";
      sha256 = "0v8ya0b58x47wp216n1zamimv4iw57cxz3xxhzix52jkw3xks9gn";
    };


    meta = with stdenv.lib; {
      description = "This is a backport of the functools standard library module from";
      homepage = "https://github.com/MiCHiLU/python-functools32";
    };
  };

  gateone = buildPythonPackage rec {
    name = "gateone-1.2-0d57c3";
    disabled = ! isPy27;
    src = pkgs.fetchFromGitHub {
      rev = "1d0e8037fbfb7c270f3710ce24154e24b7031bea";
      owner= "liftoff";
      repo = "GateOne";
      sha256 = "1ghrawlqwv7wnck6alqpbwy9mpv0y21cw2jirrvsxaracmvgk6vv";
    };
    propagatedBuildInputs = with self; [tornado futures html5lib pkgs.openssl pkgs.cacert pkgs.openssh];
    meta = {
      homepage = https://liftoffsoftware.com/;
      description = "GateOne is a web-based terminal emulator and SSH client";
      maintainers = with maintainers; [ tomberek ];

    };
    postInstall=''
    cp -R "$out/gateone/"* $out/lib/python2.7/site-packages/gateone
    '';
  };

  gcutil = buildPythonPackage rec {
    name = "gcutil-1.16.1";

    src = pkgs.fetchurl {
      url = https://dl.google.com/dl/cloudsdk/release/artifacts/gcutil-1.16.1.tar.gz;
      sha256 = "00jaf7x1ji9y46fbkww2sg6r6almrqfsprydz3q2swr4jrnrsx9x";
    };

    propagatedBuildInputs = with self; [
      gflags
      iso8601
      ipaddr
      httplib2
      google_apputils
      google_api_python_client
    ];

    prePatch = ''
      sed -i -e "s|google-apputils==0.4.0|google-apputils==0.4.1|g" setup.py
      substituteInPlace setup.py \
        --replace "httplib2==0.8" "httplib2" \
        --replace "iso8601==0.1.4" "iso8601"
    '';

    meta = {
      description = "Command-line tool for interacting with Google Compute Engine";
      homepage = "https://cloud.google.com/compute/docs/gcutil/";
      license = licenses.asl20;
      maintainers = with maintainers; [ phreedom ];
      broken = true;
    };
  };

  GeoIP = callPackage ../development/python-modules/GeoIP { };

  gmpy = buildPythonPackage rec {
    name = "gmpy-1.17";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gmpy/${name}.zip";
      sha256 = "1a79118a5332b40aba6aa24b051ead3a31b9b3b9642288934da754515da8fa14";
    };

    buildInputs = [
      pkgs.gcc
      pkgs.gmp
    ];

    meta = {
      description = "GMP or MPIR interface to Python 2.4+ and 3.x";
      homepage = http://code.google.com/p/gmpy/;
    };
  };

  gmpy2 = buildPythonPackage rec {
    name = "gmpy2-2.0.6";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gmpy2/${name}.zip";
      sha256 = "5041d0ae24407c24487106099f5bcc4abb1a5f58d90e6712cc95321975eddbd4";
    };

    buildInputs = [
      pkgs.gcc
      pkgs.gmp
      pkgs.mpfr
      pkgs.libmpc
    ];

    meta = {
      description = "GMP/MPIR, MPFR, and MPC interface to Python 2.6+ and 3.x";
      homepage = http://code.google.com/p/gmpy/;
      license = licenses.gpl3Plus;
    };
  };

  gmusicapi = with pkgs; buildPythonPackage rec {
    name = "gmusicapi-10.1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gmusicapi/gmusicapi-10.1.0.tar.gz";
      sha256 = "0smlrafh1bjzrcjzl7im8pf8f04gcnx92lf3g5qr7yzgq8k20xa2";
    };

    propagatedBuildInputs = with self; [
      validictory
      decorator
      mutagen
      protobuf
      setuptools
      requests
      dateutil
      proboscis
      mock
      appdirs
      oauth2client
      pyopenssl
      gpsoauth
      MechanicalSoup
      future
    ];

    meta = {
      description = "An unofficial API for Google Play Music";
      homepage = https://pypi.python.org/pypi/gmusicapi/;
      license = licenses.bsd3;
    };
  };

  gnureadline = buildPythonPackage rec {
    version = "6.3.3";
    name = "gnureadline-${version}";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gnureadline/${name}.tar.gz";
      sha256 = "1ghck2zz4xbqa3wz73brgjhrqj55p9hc1fq6c9zb09dnyhwb0nd2";
    };

    buildInputs = [ pkgs.ncurses ];
    patchPhase = ''
      substituteInPlace setup.py --replace "/bin/bash" "${pkgs.bash}/bin/bash"
    '';
  };

  gnutls = buildPythonPackage rec {
    name = "python-gnutls";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-gnutls/python-gnutls-3.0.0.tar.gz";
      sha256 = "1yrdxcj5rzvz8iglircz6icvyggz5fmdcd010n6w3j60yp4p84kc";
    };

    # https://github.com/AGProjects/python-gnutls/issues/2
    disabled = isPy3k;

    propagatedBuildInputs = with self; [ pkgs.gnutls ];
    patchPhase = ''
      substituteInPlace gnutls/library/__init__.py --replace "/usr/local/lib" "${pkgs.gnutls.out}/lib"
    '';
  };

  gpy = callPackage ../development/python-modules/gpy { };

  gitdb = buildPythonPackage rec {
    name = "gitdb-0.6.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gitdb/${name}.tar.gz";
      sha256 = "0n4n2c7rxph9vs2l6xlafyda5x1mdr8xy16r9s3jwnh3pqkvrsx3";
    };

    buildInputs = with self; [ nose ];
    propagatedBuildInputs = with self; [ smmap ];

    checkPhase = ''
      nosetests
    '';

    doCheck = false; # Bunch of tests fail because they need an actual git repo

    meta = {
      description = "Git Object Database";
      maintainers = with maintainers; [ ];
      homepage = https://github.com/gitpython-developers/gitdb;
      license = licenses.bsd3;
    };

  };

  GitPython = buildPythonPackage rec {
    version = "2.0.8";
    name = "GitPython-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/G/GitPython/GitPython-${version}.tar.gz";
      sha256 = "7c03d1130f903aafba6ae5b89ccf8eb433a995cd3120cbb781370e53fc4eb222";
    };

    buildInputs = with self; [ mock nose ];
    propagatedBuildInputs = with self; [ gitdb ];

    # All tests error with
    # InvalidGitRepositoryError: /tmp/nix-build-python2.7-GitPython-1.0.1.drv-0/GitPython-1.0.1
    # Maybe due to being in a chroot?
    doCheck = false;

    meta = {
      description = "Python Git Library";
      maintainers = with maintainers; [ ];
      homepage = https://github.com/gitpython-developers/GitPython;
      license = licenses.bsd3;
    };
  };

  git-annex-adapter = callPackage ../development/python-modules/git-annex-adapter {
    inherit (pkgs.gitAndTools) git-annex;
  };

  google-cloud-sdk = callPackage ../tools/admin/google-cloud-sdk { };
  google-cloud-sdk-gce = callPackage ../tools/admin/google-cloud-sdk { with-gce=true; };

  google-compute-engine = callPackage ../tools/virtualization/google-compute-engine { };

  gpapi = callPackage ../development/python-modules/gpapi { };
  gplaycli = callPackage ../development/python-modules/gplaycli { };

  gpsoauth = buildPythonPackage rec {
    version = "0.2.0";
    name = "gpsoauth-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gpsoauth/${name}.tar.gz";
      sha256 = "01zxw8rhml8xfwda7ba8983890bzwkfa55ijd6qf8qrdy6ja1ncn";
    };

    propagatedBuildInputs = with self; [
      cffi
      cryptography
      enum34
      idna
      ipaddress
      ndg-httpsclient
      pyopenssl
      pyasn1
      pycparser
      pycryptodome
      requests
      six
    ];

    meta = {
      description = "A python client library for Google Play Services OAuth";
      homepage = "https://github.com/simon-weber/gpsoauth";
      license = licenses.mit;
      maintainers = with maintainers; [ jgillich ];
    };
  };

  grip = callPackage ../development/python-modules/grip { };

  gst-python = callPackage ../development/python-modules/gst-python {
    gst-plugins-base = pkgs.gst_all_1.gst-plugins-base;
  };

  gtimelog = buildPythonPackage rec {
    name = "gtimelog-${version}";
    version = "0.9.1";

    disabled = isPy26;

    src = pkgs.fetchurl {
      url = "https://github.com/gtimelog/gtimelog/archive/${version}.tar.gz";
      sha256 = "0qk8fv8cszzqpdi3wl9vvkym1jil502ycn6sic4jrxckw5s9jsfj";
    };

    buildInputs = [ pkgs.glibcLocales ];

    LC_ALL="en_US.UTF-8";

    # TODO: AppIndicator
    propagatedBuildInputs = with self; [ pkgs.gobjectIntrospection pygobject3 pkgs.makeWrapper pkgs.gtk3 ];

    checkPhase = ''
      substituteInPlace runtests --replace "/usr/bin/env python" "${python}/bin/${python.executable}"
      ./runtests
    '';

    preFixup = ''
        wrapProgram $out/bin/gtimelog \
          --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
          --prefix LD_LIBRARY_PATH ":" "${pkgs.gtk3.out}/lib" \

    '';

    meta = {
      description = "A small Gtk+ app for keeping track of your time. It's main goal is to be as unintrusive as possible";
      homepage = http://mg.pov.lt/gtimelog/;
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ ocharles ];
      platforms = platforms.unix;
    };
  };

  gurobipy = if stdenv.system == "x86_64-darwin"
  then callPackage ../development/python-modules/gurobipy/darwin.nix {
    inherit (pkgs.darwin) cctools insert_dylib;
  }
  else if stdenv.system == "x86_64-linux"
  then callPackage ../development/python-modules/gurobipy/linux.nix {}
  else throw "gurobipy not yet supported on ${stdenv.system}";

  hbmqtt = callPackage ../development/python-modules/hbmqtt { };

  helper = buildPythonPackage rec {
    pname = "helper";
    version = "2.4.1";
    name = "${pname}-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/${pname}/${name}.tar.gz";
      sha256 = "4e33dde42ad4df30fb7790689f93d77252cff26a565610d03ff2e434865a53a2";
    };

    buildInputs = with self; [ mock ];
    propagatedBuildInputs = with self; [ pyyaml ];

    # No tests
    doCheck = false;

    meta = {
      description = "Development library for quickly writing configurable applications and daemons";
      homepage = https://helper.readthedocs.org/;
      license = licenses.bsd3;
    };


  };

  hglib = callPackage ../development/python-modules/hglib {};

  humanize = buildPythonPackage rec {
    version = "0.5.1";
    name = "humanize-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/humanize/${name}.tar.gz";
      sha256 = "a43f57115831ac7c70de098e6ac46ac13be00d69abbf60bdcac251344785bb19";
    };

    buildInputs = with self; [ mock ];

    doCheck = false;

    meta = {
      description = "Python humanize utilities";
      homepage = https://github.com/jmoiron/humanize;
      license = licenses.mit;
      maintainers = with maintainers; [ matthiasbeyer ];
      platforms = platforms.linux; # can only test on linux
    };

  };

  hupper = callPackage ../development/python-modules/hupper {};

  hovercraft = buildPythonPackage rec {
    disabled = ! isPy3k;
    name = "hovercraft-${version}";
    version = "2.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hovercraft/${name}.tar.gz";
      sha256 = "0lqxr816lymgnywln8bbv9nrmkyahjjcjkm9kjyny9bflayz4f1g";
    };

    propagatedBuildInputs = with self; [ docutils lxml manuel pygments svg-path watchdog ];

    # one test assumes we have docutils 0.12
    # TODO: enable tests after upgrading docutils to 0.12
    doCheck = false;

    meta = {
      description = "A tool to make impress.js presentations from reStructuredText";
      homepage = https://github.com/regebro/hovercraft;
      license = licenses.mit;
      maintainers = with maintainers; [ goibhniu ];
    };
  };

  hsaudiotag = buildPythonPackage (rec {
    name = "hsaudiotag-1.1.1";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hsaudiotag/${name}.tar.gz";
      sha256 = "15hgm128p8nysfi0jb127awga3vlj0iw82l50swjpvdh01m7rda8";
    };

    # no tests
    doCheck = false;

    meta = {
      description = "A pure Python library that lets one to read metadata from media files";
      homepage = http://hg.hardcoded.net/hsaudiotag/;
      license = licenses.bsd3;
    };
  });

  hsaudiotag3k = buildPythonPackage (rec {
    name = "hsaudiotag3k-1.1.3";
    disabled = !isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hsaudiotag3k/${name}.tar.gz";
      sha256 = "0bv5k5594byr2bmhh77xv10fkdpckcmxg3w380yp30aqf83rcsx3";
    };

    # no tests
    doCheck = false;

    meta = {
      description = "A pure Python library that lets one to read metadata from media files";
      homepage = http://hg.hardcoded.net/hsaudiotag/;
      license = licenses.bsd3;
    };
  });


  htmlmin = callPackage ../development/python-modules/htmlmin {};

  httpauth = buildPythonPackage rec {
    version = "0.3";
    name = "httpauth-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/httpauth/${name}.tar.gz";
      sha256 = "0qas7876igyz978pgldp5r7n7pis8n4vf0v87gxr9l7p7if5lr3l";
    };

    doCheck = false;

    meta = {
      description = "WSGI HTTP Digest Authentication middleware";
      homepage = https://github.com/jonashaag/httpauth;
      license = licenses.bsd2;
      maintainers = with maintainers; [ matthiasbeyer ];
    };
  };

  idna-ssl = callPackage ../development/python-modules/idna-ssl/default.nix { };

  ijson = callPackage ../development/python-modules/ijson/default.nix {};

  imagesize = buildPythonPackage rec {
    name = "imagesize-${version}";
    version = "0.7.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/imagesize/${name}.tar.gz";
      sha256 = "0msgz4ncp2nb5nbsxnf8kvxsl6nhwvc3b46ik097fvznl3y10gdv";
    };

    meta = {
      description = "Getting image size from png/jpeg/jpeg2000/gif file";
      homepage = https://github.com/shibukawa/imagesize_py;
      license = with licenses; [ mit ];
    };

  };

  imbalanced-learn = buildPythonPackage rec {
    name = "imbalanced-learn-${version}";
    version = "0.3.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/imbalanced-learn/${name}.tar.gz";
      sha256 = "0j76m0rrsvyqj9bimky9m7b609y5v6crf9apigww3xvcnchhj901";
    };

    preConfigure = ''
      export HOME=$PWD
    '';

    propagatedBuildInputs = with self; [ scikitlearn ];
    buildInputs = with self; [ nose pytest pandas ];

    meta = {
      description = "Library offering a number of re-sampling techniques commonly used in datasets showing strong between-class imbalance";
      homepage = https://github.com/scikit-learn-contrib/imbalanced-learn;
      license = with licenses; [ mit ];
    };

  };

  imread = buildPythonPackage rec {
    name = "python-imread-${version}";
    version = "0.6";

    src = pkgs.fetchurl {
      url = "https://github.com/luispedro/imread/archive/release-${version}.tar.gz";
      sha256 = "0i14bc67200zhzxc41g5dfp2m0pr1zaa2gv59p2va1xw0ji2dc0f";
    };

    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with self; [
      nose
      pkgs.libjpeg
      pkgs.libpng
      pkgs.libtiff
      pkgs.libwebp
    ];
    propagatedBuildInputs = with self; [ numpy ];

    meta = with stdenv.lib; {
      description = "Python package to load images as numpy arrays";
      homepage = https://imread.readthedocs.io/en/latest/;
      maintainers = with maintainers; [ luispedro ];
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  imaplib2 = callPackage ../development/python-modules/imaplib2 { };

  ipfsapi = buildPythonPackage rec {
    name = "ipfsapi-${version}";
    version = "0.4.2.post1";
    disabled = isPy26 || isPy27;

    src = pkgs.fetchFromGitHub {
      owner = "ipfs";
      repo = "py-ipfs-api";
      rev = "0c485544a114f580c65e2ffbb5782efbf7fd9f61";
      sha256 = "1v7f77cv95yv0v80gisdh71mj7jcq41xcfip6bqm57zfdbsa0xpn";
    };

    propagatedBuildInputs = with self; [ six requests ];

    meta = {
      description = "A python client library for the IPFS API";
      license = licenses.mit;
      maintainers = with maintainers; [ mguentner ];
      homepage = "https://pypi.python.org/pypi/ipfsapi";
    };
  };

  itsdangerous = buildPythonPackage rec {
    name = "itsdangerous-0.24";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/itsdangerous/${name}.tar.gz";
      sha256 = "06856q6x675ly542ig0plbqcyab6ksfzijlyf1hzhgg3sgwgrcyb";
    };

    meta = {
      description = "Helpers to pass trusted data to untrusted environments and back";
      homepage = "https://pypi.python.org/pypi/itsdangerous/";
    };
  };

  iniparse = buildPythonPackage rec {

    name = "iniparse-${version}";
    version = "0.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/iniparse/iniparse-${version}.tar.gz";
      sha256 = "0m60k46vr03x68jckachzsipav0bwhhnqb8715hm1cngs89fxhdb";
    };

    checkPhase = ''
      ${python.interpreter} runtests.py
    '';

    # Does not install tests
    doCheck = false;

    meta = with stdenv.lib; {
      description = "Accessing and Modifying INI files";
      license = licenses.mit;
      maintainers = with maintainers; [ danbst ];
    };
  };

  i3-py = buildPythonPackage rec {
    version = "0.6.4";
    name = "i3-py-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/i3-py/i3-py-${version}.tar.gz";
      sha256 = "1sgl438jrb4cdyl7hbc3ymwsf7y3zy09g1gh7ynilxpllp37jc8y";
    };

    # no tests in tarball
    doCheck = false;

    meta = {
      description = "Tools for i3 users and developers";
      homepage =  "https://github.com/ziberna/i3-py";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };

  JayDeBeApi = callPackage ../development/python-modules/JayDeBeApi {};

  jdcal = callPackage ../development/python-modules/jdcal { };

  internetarchive = callPackage ../development/python-modules/internetarchive {};

  JPype1 = callPackage ../development/python-modules/JPype1 {};

  jsbeautifier = callPackage ../development/python-modules/jsbeautifier {};

  jug = callPackage ../development/python-modules/jug {};

  jsmin = callPackage ../development/python-modules/jsmin { };

  jsonpatch = callPackage ../development/python-modules/jsonpatch { };

  jsonpickle = callPackage ../development/python-modules/jsonpickle { };

  jsonpointer = buildPythonPackage rec {
    name = "jsonpointer-1.9";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jsonpointer/${name}.tar.gz";
      sha256 = "39403b47a71aa782de6d80db3b78f8a5f68ad8dfc9e674ca3bb5b32c15ec7308";
    };

    meta = {
      description = "Resolve JSON Pointers in Python";
      homepage = "https://github.com/stefankoegl/python-json-pointer";
      license = stdenv.lib.licenses.bsd2; # "Modified BSD license, says pypi"
    };
  };

  jsonrpclib = buildPythonPackage rec {
    name = "jsonrpclib-${version}";
    version = "0.1.7";

    disabled = !isPy27;

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jsonrpclib/${name}.tar.gz";
      sha256 = "02vgirw2bcgvpcxhv5hf3yvvb4h5wzd1lpjx8na5psdmaffj6l3z";
    };

    propagatedBuildInputs = with self; [ cjson ];

    meta = {
      description = "JSON RPC client library";
      homepage = https://pypi.python.org/pypi/jsonrpclib/;
      license = stdenv.lib.licenses.asl20;
      maintainers = [ stdenv.lib.maintainers.joachifm ];
    };
  };

  jsonrpclib-pelix = callPackage ../development/python-modules/jsonrpclib-pelix {};

  jsonwatch = buildPythonPackage rec {
    name = "jsonwatch-0.2.0";

    disabled = isPyPy; # doesn't find setuptools

    src = pkgs.fetchurl {
      url = "https://github.com/dbohdan/jsonwatch/archive/v0.2.0.tar.gz";
      sha256 = "04b616ef97b9d8c3887004995420e52b72a4e0480a92dbf60aa6c50317261e06";
    };

    propagatedBuildInputs = with self; [ six ];

    meta = {
      description = "Like watch -d but for JSON";
      longDescription = ''
        jsonwatch is a command line utility with which you can track changes in
        JSON data delivered by a shell command or a web (HTTP/HTTPS) API.
        jsonwatch requests data from the designated source repeatedly at a set
        interval and displays the differences when the data changes. It is
        similar in its behavior to how watch(1) with the -d switch works
        for plain-text data.
      '';
      homepage = "https://github.com/dbohdan/jsonwatch";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };

  latexcodec = callPackage ../development/python-modules/latexcodec {};

  libsexy = callPackage ../development/python-modules/libsexy {
    libsexy = pkgs.libsexy;
  };

  libsoundtouch = callPackage ../development/python-modules/libsoundtouch { };

  libthumbor = buildPythonPackage rec {
    name = "libthumbor-${version}";
    version = "1.3.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/libthumbor/${name}.tar.gz";
      sha256 = "1vjhszsf8wl9k16wyg2rfjycjnawzl7z8j39bhiysbz5x4lqg91b";
    };

    buildInputs = with self; [ django ];

    propagatedBuildInputs = with self; [ six pycrypto ];

    doCheck = false;

    meta = {
      description = "libthumbor is the python extension to thumbor";
      homepage = https://github.com/heynemann/libthumbor;
      license = licenses.mit;
    };
  };

  lightblue = buildPythonPackage rec {
    pname = "lightblue";
    version = "0.4";
    name = "${pname}-${version}";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/${pname}/${name}.tar.gz";
      sha256 = "016h1mlhpqxjj25lcvl4fqc19k8ifmsv6df7rhr12fyfcrp5i14d";
    };

    buildInputs = [ pkgs.bluez pkgs.openobex ];


    meta = {
      homepage = http://lightblue.sourceforge.net;
      description = "Cross-platform Bluetooth API for Python";
      maintainers = with maintainers; [ leenaars ];
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };


  lightning = buildPythonPackage rec {
    version = "1.2.1";
    name = "lightning-python-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/lightning-python/${name}.tar.gz";
      sha256 = "3987d7d4a634bdb6db9bcf212cf4d2f72bab5bc039f4f6cbc02c9d01c4ade792";
    };

    buildInputs = with self; [ pytest ];

    propagatedBuildInputs = with self; [
      jinja2
      matplotlib
      numpy
      requests
      six
    ];

    meta = {
      description = "A Python client library for the Lightning data visualization server";
      homepage = http://lightning-viz.org;
      license = licenses.mit;
    };
  };

  jupyter = buildPythonPackage rec {
    version = "1.0.0";
    name = "jupyter-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jupyter/${name}.tar.gz";
      sha256 = "d9dc4b3318f310e34c82951ea5d6683f67bed7def4b259fafbfe4f1beb1d8e5f";
    };

    propagatedBuildInputs = with self; [
      notebook
      qtconsole
      jupyter_console
      nbconvert
      ipykernel
      ipywidgets
    ];

    # Meta-package, no tests
    doCheck = false;

    meta = {
      description = "Installs all the Jupyter components in one go";
      homepage = "http://jupyter.org/";
      license = licenses.bsd3;
      platforms = platforms.all;
      priority = 100; # This is a metapackage which is unimportant
    };
  };

  jupyter_console = callPackage ../development/python-modules/jupyter_console { };

  jupyterlab = buildPythonPackage rec {
    name = "jupyterlab-${version}";
    version = "0.4.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jupyterlab/${name}.tar.gz";
      sha256 = "91dc4d7dfb1e6ab97e28d6e3a2fc38f5f65d368201c00fd0ed077519258e67bb";
    };

    propagatedBuildInputs = with self; [ notebook ];

    # No tests in archive
    doCheck = false;

    meta = {
      description = "Jupyter lab environment notebook server extension.";
      license = with licenses; [ bsd3 ];
      homepage = "http://jupyter.org/";
    };
  };

  PyLTI = callPackage ../development/python-modules/pylti { };

  lmdb = buildPythonPackage rec {
    pname = "lmdb";
    version = "0.92";
    name = "${pname}-${version}";

    src = self.fetchPypi {
      inherit pname version;
      sha256 = "01nw6r08jkipx6v92kw49z34wmwikrpvc5j9xawdiyg1n2526wrx";
    };

    # Some sort of mysterious failure with lmdb.tool
    doCheck = !isPy3k;

    meta = {
      description = "Universal Python binding for the LMDB 'Lightning' Database";
      homepage = "https://github.com/dw/py-lmdb";
      license = licenses.openldap;
      maintainers = with maintainers; [ copumpkin ];
    };
  };

  logilab_astng = buildPythonPackage rec {
    name = "logilab-astng-0.24.3";

    src = pkgs.fetchurl {
      url = "http://download.logilab.org/pub/astng/${name}.tar.gz";
      sha256 = "0np4wpxyha7013vkkrdy54dvnil67gzi871lg60z8lap0l5h67wn";
    };

    propagatedBuildInputs = with self; [ logilab_common ];
  };

  lpod = buildPythonPackage rec {
    version = "1.1.7";
    name = "python-lpod-${version}";
    # lpod library currently does not support Python 3.x
    disabled = isPy3k;

    propagatedBuildInputs = with self; [ lxml docutils pillow ];

    src = pkgs.fetchFromGitHub {
      owner = "lpod";
      repo = "lpod-python";
      rev = "dee32120ee582ff337b0c52a95a9a87cca71fd67";
      sha256 = "1mikvzp27wxkzpr2lii4wg1hhx8h610agckqynvsrdc8v3nw9ciw";
    };

    meta = {
      homepage = https://github.com/lpod/lpod-python/;
      description = "Library implementing the ISO/IEC 26300 OpenDocument Format standard (ODF) ";
      license = licenses.gpl3;
    };
  };

  luftdaten = callPackage ../development/python-modules/luftdaten { };

  m2r = callPackage ../development/python-modules/m2r { };

  mailchimp = buildPythonPackage rec {
    version = "2.0.9";
    name = "mailchimp-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mailchimp/mailchimp-${version}.tar.gz";
      sha256 = "0351ai0jqv3dzx0xxm1138sa7mb42si6xfygl5ak8wnfc95ff770";
    };

    buildInputs = with self; [ docopt ];
    propagatedBuildInputs = with self; [ requests ];
    patchPhase = ''
      sed -i 's/==/>=/' setup.py
    '';

    meta = {
      description = "A CLI client and Python API library for the MailChimp email platform";
      homepage = "http://apidocs.mailchimp.com/api/2.0/";
      license = licenses.mit;
    };
  };

  python-mapnik = buildPythonPackage rec {
    name = "python-mapnik-${version}";
    version = "3.0.13";

    src = pkgs.fetchFromGitHub {
      owner = "mapnik";
      repo = "python-mapnik";
      rev = "v${version}";
      sha256 = "0biw9bfkbsgfyjihyvkj4abx9s9r3h81rk6dc1y32022rypsqhkp";
    };

    disabled = isPyPy;
    doCheck = false; # doesn't find needed test data files
    buildInputs = with pkgs;
      [ boost cairo harfbuzz icu libjpeg libpng libtiff libwebp mapnik proj zlib ];
    propagatedBuildInputs = with self; [ pillow pycairo ];

    meta = with stdenv.lib; {
      description = "Python bindings for Mapnik";
      homepage = http://mapnik.org;
      license  = licenses.lgpl21;
    };
  };

  mt-940 = callPackage ../development/python-modules/mt-940 { };

  mwlib = let
    pyparsing = buildPythonPackage rec {
      name = "pyparsing-1.5.7";
      disabled = isPy3k;

      src = pkgs.fetchurl {
        url = "mirror://pypi/p/pyparsing/${name}.tar.gz";
        sha256 = "646e14f90b3689b005c19ac9b6b390c9a39bf976481849993e277d7380e6e79f";
      };
      meta = {
        homepage = http://pyparsing.wikispaces.com/;
        description = "An alternative approach to creating and executing simple grammars, vs. the traditional lex/yacc approach, or the use of regular expressions";
      };
    };
  in buildPythonPackage rec {
    version = "0.15.15";
    name = "mwlib-${version}";

    src = pkgs.fetchurl {
      url = "http://pypi.pediapress.com/packages/mirror/${name}.tar.gz";
      sha256 = "1dnmnkc21zdfaypskbpvkwl0wpkpn0nagj1fc338w64mbxrk8ny7";
    };

    propagatedBuildInputs = with self; [
        apipkg
        bottle
        gevent
        lxml
        odfpy
        pillow
        py
        pyPdf
        pyparsing
        qserve
        roman
        simplejson
        sqlite3dbm
        timelib
    ];

    checkInputs = with self; [ pytest ];

    checkPhase = ''
      py.test
    '';

    # Tests are in build directory but we need extension modules that are in $out
    doCheck = false;

    meta = {
      description = "Library for parsing MediaWiki articles and converting them to different output formats";
      homepage = "http://pediapress.com/code/";
      license = licenses.bsd3;
      broken = true; # Requires different versions of packages
    };
  };

  mwlib-ext = buildPythonPackage rec {
    version = "0.13.2";
    name = "mwlib.ext-${version}";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "http://pypi.pediapress.com/packages/mirror/${name}.zip";
      sha256 = "9229193ee719568d482192d9d913b3c4bb96af7c589d6c31ed4a62caf5054278";
    };

    meta = {
      description = "Dependencies for mwlib markup";
      homepage = "http://pediapress.com/code/";
      license = licenses.bsd3;
    };
  };

  mwlib-rl = buildPythonPackage rec {
    version = "0.14.6";
    name = "mwlib.rl-${version}";

    src = pkgs.fetchurl {
      url = "http://pypi.pediapress.com/packages/mirror/${name}.zip";
      sha256 = "7f596fd60eb24d8d3da3ab4880f095294028880eafb653810a7bdaabdb031238";
    };

    buildInputs = with self;
      [
        mwlib
        mwlib-ext
        pygments
      ];

    meta = {
      description = "Generate pdfs from mediawiki markup";
      homepage = "http://pediapress.com/code/";
      license = licenses.bsd3;
    };
  };

  natsort = callPackage ../development/python-modules/natsort { };

  logster = buildPythonPackage {
    name = "logster-7475c53822";
    src = pkgs.fetchgit {
      url = git://github.com/etsy/logster;
      rev = "7475c53822";
      sha256 = "0565wxxiwksnly8rakb2r77k7lwzniq16kv861qd2ns9hgsjgy31";
    };
  };

  ncclient = callPackage ../development/python-modules/ncclient {};

  logfury = callPackage ../development/python-modules/logfury { };

  ndg-httpsclient = buildPythonPackage rec {
    version = "0.4.2";
    name = "ndg-httpsclient-${version}";

    propagatedBuildInputs = with self; [ pyopenssl ];

    src = pkgs.fetchFromGitHub {
      owner = "cedadev";
      repo = "ndg_httpsclient";
      rev = version;
      sha256 = "1kk4knv029j0cicfiv23c1rayc1n3f1j3rhl0527gxiv0qv4jw8h";
    };

    # uses networking
    doCheck = false;

    meta = {
      homepage = https://github.com/cedadev/ndg_httpsclient/;
      description = "Provide enhanced HTTPS support for httplib and urllib2 using PyOpenSSL";
      license = licenses.bsd2;
      maintainers = with maintainers; [ ];
    };
  };

  netcdf4 = callPackage ../development/python-modules/netcdf4 { };

  netdisco = callPackage ../development/python-modules/netdisco { };

  Nikola = callPackage ../development/python-modules/Nikola { };

  nxt-python = buildPythonPackage rec {
    version = "unstable-20160819";
    pname = "nxt-python";
    name = "${pname}-${version}";

    propagatedBuildInputs = with self; [ pyusb pybluez pyfantom pkgs.git ];
    disabled = isPy3k;

    src = pkgs.fetchgit {
      url = "http://github.com/Eelviny/nxt-python";
      rev = "479e20b7491b28567035f4cee294c4a2af629297";
      sha256 = "0mcsajhgm2wy4iy2lhmyi3xibgmbixbchanzmlhsxk6qyjccn9r9";
      branchName= "pyusb";
    };

    # Tests fail on Mac dependency
    doCheck = false;

    meta = {
      description = "Python driver/interface for Lego Mindstorms NXT robot";
      homepage = https://github.com/Eelviny/nxt-python;
      license = licenses.gpl3;
      platforms = platforms.linux;
      maintainers = with maintainers; [ leenaars ];
    };
  };

  odfpy = callPackage ../development/python-modules/odfpy { };

  oset = callPackage ../development/python-modules/oset { };

  pamela = buildPythonPackage rec {
    name = "pamela-${version}";
    version = "0.3.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pamela/${name}.tar.gz";
      sha256 = "0ssxbqsshrm8p642g3h6wsq20z1fsqhpdvqdm827gn6dlr38868y";
    };

    postUnpack = ''
      substituteInPlace $sourceRoot/pamela.py --replace \
        'find_library("pam")' \
        '"${getLib pkgs.pam}/lib/libpam.so"'
    '';

    doCheck = false;

    meta = {
      description = "PAM interface using ctypes";
      homepage = "http://github.com/minrk/pamela";
      license = licenses.mit;
    };
  };

  # These used to be here but were moved to all-packages, but I'll leave them around for a while.
  pants = pkgs.pants;

  paperwork-backend = callPackage ../applications/office/paperwork/backend.nix { };

  papis-python-rofi = callPackage ../development/python-modules/papis-python-rofi { };

  pathspec = callPackage ../development/python-modules/pathspec { };

  pathtools = buildPythonPackage rec {
    name = "pathtools-${version}";
    version = "0.1.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pathtools/${name}.tar.gz";
      sha256 = "1h7iam33vwxk8bvslfj4qlsdprdnwf8bvzhqh3jq5frr391cadbw";
    };

    meta = {
      description = "Pattern matching and various utilities for file systems paths";
      homepage = https://github.com/gorakhargosh/pathtools;
      license = licenses.mit;
      maintainers = with maintainers; [ goibhniu ];
    };
  };

  paver = buildPythonPackage rec {
    version = "1.2.2";
    name    = "Paver-${version}";

    src = pkgs.fetchurl {
      url    = "mirror://pypi/P/Paver/Paver-${version}.tar.gz";
      sha256 = "0lix9d33ndb3yk56sm1zlj80fbmxp0w60yk0d9pr2xqxiwi88sqy";
    };

    buildInputs = with self; [ cogapp mock virtualenv ];

    propagatedBuildInputs = with self; [ nose ];

    # the tests do not pass
    doCheck = false;

    meta = {
      description = "A Python-based build/distribution/deployment scripting tool";
      homepage    = http://github.com/paver/paver;
      maintainers = with maintainers; [ lovek323 ];
      platforms   = platforms.unix;
    };
  };

  passlib = callPackage ../development/python-modules/passlib { };

  path-and-address = buildPythonPackage rec {
    version = "2.0.1";
    name = "path-and-address-${version}";

    buildInputs = with self; [ pytest ];

    checkPhase = "py.test";

    src = pkgs.fetchFromGitHub {
      owner = "joeyespo";
      repo = "path-and-address";
      rev = "v${version}";
      sha256 = "0b0afpsaim06mv3lhbpm8fmawcraggc11jhzr6h72kdj1cqjk5h6";
    };

    meta = {
      description = "Functions for server CLI applications used by humans";
      homepage = https://github.com/joeyespo/path-and-address;
      license = licenses.mit;
      maintainers = with maintainers; [ koral];
    };
  };


  pdfminer = buildPythonPackage rec {
    version = "20140328";
    name = "pdfminer-${version}";

    disabled = ! isPy27;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pdfminer/pdfminer-${version}.tar.gz";
      sha256 = "0qpjv4b776dwvpf5a7v19g41qsz97bv0qqsyvm7a31k50n9pn65s";
    };

    propagatedBuildInputs = with self; [  ];

    meta = {
      description = "Tool for extracting information from PDF documents";
      homepage = http://euske.github.io/pdfminer/index.html;
      license = licenses.mit;
      maintainers = with maintainers; [ ];
    };
  };

  peppercorn = buildPythonPackage rec {
    name = "peppercorn-0.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/peppercorn/${name}.tar.gz";
      sha256 = "921cba5d51fa211e6da0fbd2120b9a98d663422a80f5bb669ad81ffb0909774b";
    };

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };

  pex = buildPythonPackage rec {
    name = "pex-${version}";
    version = "1.2.7";

    src = self.fetchPypi {
      pname  = "pex";
      sha256 = "1m0gx9182w1dybkyjwwjyd6i87x2dzv252ks2fj8yn6avlcp5z4q";
      inherit version;
    };

    prePatch = ''
      substituteInPlace setup.py --replace 'SETUPTOOLS_REQUIREMENT,' '"setuptools"'
    '';

    # A few more dependencies I don't want to handle right now...
    doCheck = false;

    meta = {
      description = "A library and tool for generating .pex (Python EXecutable) files";
      homepage = "https://github.com/pantsbuild/pex";
      license = licenses.asl20;
      maintainers = with maintainers; [ copumpkin ];
    };
  };

  phpserialize = callPackage ../development/python-modules/phpserialize { };

  plaster = callPackage ../development/python-modules/plaster {};

  plaster-pastedeploy = callPackage ../development/python-modules/plaster-pastedeploy {};

  plotly = callPackage ../development/python-modules/plotly { };

  plyfile = callPackage ../development/python-modules/plyfile { };

  podcastparser = callPackage ../development/python-modules/podcastparser { };

  pomegranate = callPackage ../development/python-modules/pomegranate { };

  poppler-qt4 = buildPythonPackage rec {
    name = "poppler-qt4-${version}";
    version = "0.18.1";
    disabled = isPy3k || isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-poppler-qt4/" +
            "python-poppler-qt4-${version}.tar.gz";
      sha256 = "00e3f89f4e23a844844d082918a89c2cbb1e8231ecb011b81d592e7e3c33a74c";
    };

    propagatedBuildInputs = [ self.pyqt4 pkgs.pkgconfig pkgs.poppler_qt4 ];

    preBuild = "${python}/bin/${python.executable} setup.py build_ext" +
               " --include-dirs=${pkgs.poppler_qt4.dev}/include/poppler/";

    NIX_CFLAGS_COMPILE = "-I${pkgs.poppler_qt4.dev}/include/poppler/";

    meta = {
      description = "A Python binding to Poppler-Qt4";
      longDescription = ''
        A Python binding to Poppler-Qt4 that aims for completeness
        and for being actively maintained.
      '';
      license = licenses.lgpl21Plus;
      maintainers = with maintainers; [ sepi ];
      platforms = platforms.all;
    };
  };

  poyo = buildPythonPackage rec {
    version = "0.4.0";
    name = "poyo-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/poyo/${name}.tar.gz";
      sha256 = "1f48ffl0j1f2lmgabajps7v8w90ppxbp5168gh8kh27bjd8xk5ca";
    };

    meta = {
      homepage = https://github.com/hackebrot/poyo;
      description = "A lightweight YAML Parser for Python";
      license = licenses.mit;
    };
  };

  prov = callPackage ../development/python-modules/prov { };

  pudb = buildPythonPackage rec {
    name = "pudb-2016.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pudb/${name}.tar.gz";
      sha256 = "0njhi49d9fxbwh5p8yjx8m3jlfyzfm00b5aff6bz473pn7vxfn79";
    };

    propagatedBuildInputs = with self; [ pygments urwid ];

    # Tests fail on python 3 due to writes to the read-only home directory
    doCheck = !isPy3k;

    meta = {
      description = "A full-screen, console-based Python debugger";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };

  pybtex = callPackage ../development/python-modules/pybtex {};

  pybtex-docutils = callPackage ../development/python-modules/pybtex-docutils {};

  pycallgraph = buildPythonPackage rec {
    name = "pycallgraph-${version}";
    version = "1.0.1";

    src = pkgs.fetchurl {
      url = mirror://pypi/p/pycallgraph/pycallgraph-1.0.1.tar.gz;
      sha256 = "0w8yr43scnckqcv5nbyd2dq4kpv74ai856lsdsf8iniik07jn9mi";
    };

    buildInputs = with self; [ pytest ];

    # Tests do not work due to this bug: https://github.com/gak/pycallgraph/issues/118
    doCheck = false;

    meta = {
      homepage = http://pycallgraph.slowchop.com;
      description = "Call graph visualizations for Python applications";
      maintainers = with maintainers; [ auntie ];
      license = licenses.gpl2;
      platforms = platforms.all;
    };
  };

  pycassa = callPackage ../development/python-modules/pycassa { };

  pyblake2 = callPackage ../development/python-modules/pyblake2 { };

  pybluez = buildPythonPackage rec {
    version = "unstable-20160819";
    pname = "pybluez";
    name = "${pname}-${version}";

    propagatedBuildInputs = with self; [ pkgs.bluez ];

    src = pkgs.fetchFromGitHub {
      owner = "karulis";
      repo = "${pname}";
      rev = "a0b226a61b166e170d48539778525b31e47a4731";
      sha256 = "104dm5ngfhqisv1aszdlr3szcav2g3bhsgzmg4qfs09b3i5zj047";
    };

    # the tests do not pass
    doCheck = false;

    meta = {
      description = "Bluetooth Python extension module";
      license = licenses.gpl2;
      maintainers = with maintainers; [ leenaars ];
    };
  };

  pycares = buildPythonPackage rec {
    name = "pycares-${version}";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pycares/${name}.tar.gz";
      sha256 = "a18341ea030e2cc0743acdf4aa72302bdf6b820938b36ce4bd76e43faa2276a3";
    };

    propagatedBuildInputs = [ pkgs.c-ares ];

    # No tests included
    doCheck = false;

    meta = {
      homepage = https://github.com/saghul/pycares;
      description = "Interface for c-ares";
      license = licenses.mit;
    };
  };

  pycuda = callPackage ../development/python-modules/pycuda rec {
    cudatoolkit = pkgs.cudatoolkit75;
    inherit (pkgs.stdenv) mkDerivation;
  };

  pydotplus = callPackage ../development/python-modules/pydotplus { };

  pyhomematic = callPackage ../development/python-modules/pyhomematic { };

  pylama = callPackage ../development/python-modules/pylama { };

  pyphen = callPackage ../development/python-modules/pyphen {};

  pypoppler = buildPythonPackage rec {
    name = "pypoppler-${version}";
    version = "0.12.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pypoppler/${name}.tar.gz";
      sha256 = "47e6ac99e5b114b9abf2d1dd1bca06f22c028d025432512989f659142470810f";
    };

    NIX_CFLAGS_COMPILE="-I${pkgs.poppler.dev}/include/poppler/";
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.poppler.dev ];
    propagatedBuildInputs = with self; [ pycairo pygobject2 ];

    patches = [
      ../development/python-modules/pypoppler-0.39.0.patch
      ../development/python-modules/pypoppler-poppler.c.patch
    ];

    # Not supported.
    disabled = isPy3k;

    # No tests in archive
    doCheck = false;

    meta = {
      homepage = https://code.launchpad.net/~mriedesel/poppler-python/main;
      description = "Python bindings for poppler-glib, unofficial branch including bug fixes, and removal of gtk dependencies";
      license = licenses.gpl2;
    };
  };

  pypillowfight = buildPythonPackage rec {
    name = "pypillowfight-${version}";
    version = "0.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "jflesch";
      repo = "libpillowfight";
      rev = version;
      sha256 = "1rwmajsy9qhl3qhhy5mw0xmr3n8abxcq8baidpn0sxv6yjg2369z";
    };

    # Disable tests because they're designed to only work on Debian:
    # https://github.com/jflesch/libpillowfight/issues/2#issuecomment-268259174
    doCheck = false;

    # Python 2.x is not supported, see:
    # https://github.com/jflesch/libpillowfight/issues/1
    disabled = !isPy3k && !isPyPy;

    # This is needed by setup.py regardless of whether tests are enabled.
    buildInputs = [ self.nose ];
    propagatedBuildInputs = [ self.pillow ];

    meta = {
      description = "Library containing various image processing algorithms";
      homepage = "https://github.com/jflesch/libpillowfight";
      license = licenses.gpl3Plus;
    };
  };

  python-axolotl = callPackage ../development/python-modules/python-axolotl { };

  python-axolotl-curve25519 = callPackage ../development/python-modules/python-axolotl-curve25519 { };

  pythonix = toPythonModule (callPackage ../development/python-modules/pythonix { });

  pyramid = buildPythonPackage rec {
    pname = "pyramid";
    version = "1.9.1";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0dhbzc4q0vsnv3aihy728aczg56xs6h9s1rmvr096q4lb6yln3w4";
    };

    checkInputs = with self; [
      docutils
      virtualenv
      webtest
      zope_component
    ] ++ optional isPy26 unittest2;

    propagatedBuildInputs = with self; [
      hupper
      PasteDeploy
      plaster
      plaster-pastedeploy
      repoze_lru
      repoze_sphinx_autointerface
      translationstring
      venusian
      webob
      zope_deprecation
      zope_interface
    ];

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };

    # Failing tests
    # https://github.com/Pylons/pyramid/issues/1899
    doCheck = !isPy35;

  };

  pyramid_beaker = callPackage ../development/python-modules/pyramid_beaker { };

  pyramid_chameleon = buildPythonPackage rec {
    name = "pyramid_chameleon-0.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyramid_chameleon/${name}.tar.gz";
      sha256 = "d176792a50eb015d7865b44bd9b24a7bd0489fa9a5cebbd17b9e05048cef9017";
    };

    propagatedBuildInputs = with self; [
      chameleon
      pyramid
      zope_interface
      setuptools
    ];

    meta = {
      maintainers = with maintainers; [ domenkozar ];
    };
  };


  pyramid_jinja2 = buildPythonPackage rec {
    name = "pyramid_jinja2-${version}";
    version = "2.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyramid_jinja2/${name}.tar.gz";
      sha256 = "93c86e3103b454301f4d66640191aba047f2ab85ba75647aa18667b7448396bd";
    };

    buildInputs = with self; [ webtest ];
    propagatedBuildInputs = with self; [ jinja2 pyramid ];

    meta = {
      maintainers = with maintainers; [ domenkozar ];
      platforms = platforms.all;
    };
  };


  pyramid_mako = buildPythonPackage rec {
    name = "pyramid_mako-0.3.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyramid_mako/${name}.tar.gz";
      sha256 = "00811djmsc4rz20kpy2paam05fbx6dmrv2i5jf90f6xp6zw4isy6";
    };

    buildInputs = with self; [ webtest ];
    propagatedBuildInputs = with self; [ pyramid Mako ];
  };


  pyramid_exclog = buildPythonPackage rec {
    name = "pyramid_exclog-0.7";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyramid_exclog/${name}.tar.gz";
      sha256 = "a58c82866c3e1a350684e6b83b440d5dc5e92ca5d23794b56d53aac06fb65a2c";
    };

    propagatedBuildInputs = with self; [ pyramid ];

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };


  pyramid_multiauth = buildPythonPackage rec {
    name = "pyramid_multiauth-${version}";
    version = "0.8.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyramid_multiauth/${name}.tar.gz";
      sha256 = "1lq292qakrm4ixi4vaif8dqywzj08pn6qy0wi4gw28blh39p0msk";
    };

    propagatedBuildInputs = with self; [ pyramid ];

    meta = {
      description = "Authentication policy for Pyramid that proxies to a stack of other authentication policies";
      homepage = https://github.com/mozilla-services/pyramid_multiauth;
    };
  };

  pyramid_hawkauth = buildPythonPackage rec {
    name = "pyramidhawkauth-${version}";
    version = "0.1.0";
    src = pkgs.fetchgit {
      url = https://github.com/mozilla-services/pyramid_hawkauth.git;
      rev = "refs/tags/v${version}";
      sha256 = "038ign7qlavlmvrhb2y8bygbxvy4j7bx2k1zg0i3wblg2ja50w7h";
    };

    propagatedBuildInputs = with self; [ pyramid hawkauthlib tokenlib ];
    buildInputs = with self; [ webtest ];
  };

  pyroute2 = callPackage ../development/python-modules/pyroute2 { };

  pyspf = callPackage ../development/python-modules/pyspf { };

  pysrt = callPackage ../development/python-modules/pysrt { };

  pytools = callPackage ../development/python-modules/pytools { };

  pytun = buildPythonPackage rec {
    name = "pytun-${version}";
    version = "2.2.1";
    rev = "v${version}";

    src = pkgs.fetchFromGitHub {
      inherit rev;
      owner = "montag451";
      repo = "pytun";
      sha256 = "1bxk0z0v8m0b01xg94f039j3bsclkshb7girvjqfzk5whbd2nryh";
    };

    doCheck = false;

    meta = {
      homepage = https://github.com/montag451/pytun;
      description = "Linux TUN/TAP wrapper for Python";
      license = licenses.mit;
      maintainers = with maintainers; [ montag451 ];
      platforms = platforms.linux;
    };
  };

  python-ctags3 = callPackage ../development/python-modules/python-ctags3 { };

  junos-eznc = callPackage ../development/python-modules/junos-eznc {};

  raven = callPackage ../development/python-modules/raven { };

  rethinkdb = buildPythonPackage rec {
    name = "rethinkdb-${version}";
    version = "2.3.0.post6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/rethinkdb/${name}.tar.gz";
      sha256 = "05qwkmq6kn437ywyjs02jxbry720gw39q4z4jdb0cnbbi76lwddm";
    };

    doCheck = false;

    meta = {
      description = "Python driver library for the RethinkDB database server";
      homepage = "https://pypi.python.org/pypi/rethinkdb";
      license = licenses.agpl3;
    };
  };

  roman = buildPythonPackage rec {
    version = "2.0.0";
    name = "roman-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/roman/${name}.zip";
      sha256 = "90e83b512b44dd7fc83d67eb45aa5eb707df623e6fc6e66e7f273abd4b2613ae";
    };

    buildInputs = with self; with pkgs; [ ];

    propagatedBuildInputs = with self; [ ];

    meta = {
      description = "Integer to Roman numerals converter";
      homepage = "https://pypi.python.org/pypi/roman";
      license = licenses.psfl;
    };
  };



  librosa = buildPythonPackage rec {
    pname = "librosa";
    name = "${pname}-${version}";
    version = "0.4.3";
    src = pkgs.fetchurl {
      url = "mirror://pypi/${builtins.substring 0 1 pname}/${pname}/${name}.tar.gz";
      sha256 = "209626c53556ca3922e52d2fae767bf5b398948c867fcc8898f948695dacb247";
    };

    propagatedBuildInputs = with self; [ joblib matplotlib six scikitlearn
      decorator audioread resampy ];

    # No tests
    doCheck = false;

    meta = {
      description = "Python module for audio and music processing";
      homepage = http://librosa.github.io/;
      license = licenses.isc;
    };
  };

  joblib = callPackage ../development/python-modules/joblib { };

  safe = buildPythonPackage rec {
    version = "0.4";
    name = "Safe-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/S/Safe/${name}.tar.gz";
      sha256 = "a2fdac9fe8a9dcf02b438201d6ce0b7be78f85dc6492d03edfb89be2adf489de";
    };

    buildInputs = with self; [ nose ];
    meta = {
      homepage = "https://github.com/lepture/safe";
      license = licenses.bsd3;
      description = "Check password strength";
    };
  };

  samplerate = buildPythonPackage rec {
    name = "scikits.samplerate-${version}";
    version = "0.3.3";
    src = pkgs.fetchgit {
      url = https://github.com/cournape/samplerate;
      rev = "a536c97eb2d6195b5f266ea3cc3a35364c4c2210";
      sha256 = "0mgic7bs5zv5ji05vr527jlxxlb70f9dg93hy1lzyz2plm1kf7gg";
    };

    buildInputs = with self;  [ pkgs.libsamplerate ];

    propagatedBuildInputs = with self; [ numpy ];

    preConfigure = ''
       cat > site.cfg << END
       [samplerate]
       library_dirs=${pkgs.libsamplerate.out}/lib
       include_dirs=${pkgs.libsamplerate.dev}/include
       END
    '';

    doCheck = false;
  };

  sarge = callPackage ../development/python-modules/sarge { };

  subliminal = callPackage ../development/python-modules/subliminal {};

  hyperlink = callPackage ../development/python-modules/hyperlink {};

  zope_copy = callPackage ../development/python-modules/zope_copy {};

  ssdeep = buildPythonPackage rec {
    name = "ssdeep-3.1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/ssdeep/${name}.tar.gz";
      sha256 = "1p9dpykmnfb73cszdiic5wbz5bmbbmkiih08pb4dah5mwq4n7im6";
    };

    buildInputs = with pkgs; [ ssdeep ];
    propagatedBuildInputs = with self; [ cffi six ];
    meta.broken = true; # Tests fail, and no reverse-dependencies anyway
  };

  s2clientprotocol = callPackage ../development/python-modules/s2clientprotocol { };

  statsd = buildPythonPackage rec {
    name = "statsd-${version}";
    version = "3.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/statsd/${name}.tar.gz";
      sha256 = "3fa92bf0192af926f7a0d9be031fe3fd0fbaa1992d42cf2f07e68f76ac18288e";
    };

    buildInputs = with self; [ nose mock ];

    meta = {
      maintainers = with maintainers; [ domenkozar ];
      description = "A simple statsd client";
      license = licenses.mit;
      homepage = https://github.com/jsocol/pystatsd;
    };

    patchPhase = ''
      # Failing test: ERROR: statsd.tests.test_ipv6_resolution_udp
      sed -i 's/test_ipv6_resolution_udp/noop/' statsd/tests.py
      # well this is a noop, but so it was before
      sed -i 's/assert_called_once()/called/' statsd/tests.py
    '';

  };

  py3status = buildPythonPackage rec {
    version = "3.7";
    name = "py3status-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "ultrabug";
      repo = "py3status";
      rev = version;
      sha256 = "1khrvxjjcm1bsswgrdgvyrdrimxx92yhql4gmji6a0kpp59dp541";
    };
    doCheck = false;
    propagatedBuildInputs = with self; [ requests ];
    buildInputs = with pkgs; [ file ];
    prePatch = ''
      sed -i -e "s|'file|'${pkgs.file}/bin/file|" py3status/parse_config.py
      sed -i -e "s|\[\"acpi\"|\[\"${pkgs.acpi}/bin/acpi\"|" py3status/modules/battery_level.py
      sed -i -e "s|notify-send|${pkgs.libnotify}/bin/notify-send|" py3status/modules/battery_level.py
      sed -i -e "s|/usr/bin/whoami|${pkgs.coreutils}/bin/whoami|" py3status/modules/external_script.py
      sed -i -e "s|'amixer|'${pkgs.alsaUtils}/bin/amixer|" py3status/modules/volume_status.py
      sed -i -e "s|'i3-nagbar|'${pkgs.i3}/bin/i3-nagbar|" py3status/modules/pomodoro.py
      sed -i -e "s|'free|'${pkgs.procps}/bin/free|" py3status/modules/sysdata.py
      sed -i -e "s|'sensors|'${pkgs.lm_sensors}/bin/sensors|" py3status/modules/sysdata.py
      sed -i -e "s|'setxkbmap|'${pkgs.xorg.setxkbmap}/bin/setxkbmap|" py3status/modules/keyboard_layout.py
      sed -i -e "s|'xset|'${pkgs.xorg.xset}/bin/xset|" py3status/modules/keyboard_layout.py
    '';
    meta = {
      maintainers = with maintainers; [ garbas ];
    };
  };

  multi_key_dict = buildPythonPackage rec {
    name = "multi_key_dict-${version}";
    version = "2.0.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/multi_key_dict/multi_key_dict-${version}.tar.gz";
      sha256 = "17lkx4rf4waglwbhc31aak0f28c63zl3gx5k5i1iq2m3gb0xxsyy";
    };

    meta = with stdenv.lib; {
      description = "multi_key_dict";
      homepage = "https://github.com/formiaczek/multi_key_dict";
    };
  };


  pyrtlsdr = callPackage ../development/python-modules/pyrtlsdr { };

  random2 = self.buildPythonPackage rec {
    name = "random2-1.0.1";

    doCheck = !isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/random2/${name}.zip";
      sha256 = "34ad30aac341039872401595df9ab2c9dc36d0b7c077db1cea9ade430ed1c007";
    };
  };

  scandir = callPackage ../development/python-modules/scandir { };

  schedule = buildPythonPackage rec {
    name = "schedule-0.3.2";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/10/96/d101fab391753ebc81fa3bb0e744df1ddcfb032c31b036d38083f8994db1/schedule-0.3.2.tar.gz";
      sha256 = "1h0waw4jd5ql68y5kxb9irwapkbkwfs1w0asvbl24fq5f8czdijm";
    };

    buildInputs = with self; [ mock ];

    meta = with stdenv.lib; {
      description = "Python job scheduling for humans";
      homepage = https://github.com/dbader/schedule;
      license = licenses.mit;
    };
  };

  schema = callPackage ../development/python-modules/schema {};

  stem = buildPythonPackage rec {
    name = "stem-${version}";
    version = "1.6.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/stem/${name}.tar.gz";
      sha256 = "1va9p3ij7lxg6ixfsvaql06dn11l3fgpxmss1dhlvafm7sqizznp";
    };

    meta = {
      description = "Controller library that allows applications to interact with Tor (https://www.torproject.org/";
      homepage = https://stem.torproject.org/;
      license = licenses.gpl3;
      maintainers = with maintainers; [ phreedom ];
    };

  };

  svg-path = callPackage ../development/python-modules/svg-path { };

  regex = callPackage ../development/python-modules/regex { };

  repoze_lru = buildPythonPackage rec {
    name = "repoze.lru-0.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/repoze.lru/${name}.tar.gz";
      sha256 = "0f7a323bf716d3cb6cb3910cd4fccbee0b3d3793322738566ecce163b01bbd31";
    };

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };

  repoze_sphinx_autointerface = buildPythonPackage rec {
    name = "repoze.sphinx.autointerface-0.7.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/repoze.sphinx.autointerface/${name}.tar.gz";
      sha256 = "97ef5fac0ab0a96f1578017f04aea448651fa9f063fc43393a8253bff8d8d504";
    };

    propagatedBuildInputs = with self; [ zope_interface sphinx ];

    meta = {
      maintainers = with maintainers; [ domenkozar ];
      platforms = platforms.all;
    };
  };


  setuptools-git = buildPythonPackage rec {
    name = "setuptools-git-${version}";
    version = "1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/setuptools-git/${name}.tar.gz";
      sha256 = "047d7595546635edebef226bc566579d422ccc48a8a91c7d32d8bd174f68f831";
    };

    propagatedBuildInputs = [ pkgs.git ];
    doCheck = false;

    meta = {
      description = "Setuptools revision control system plugin for Git";
      homepage = https://pypi.python.org/pypi/setuptools-git;
      license = licenses.bsd3;
    };
  };


  watchdog = buildPythonPackage rec {
    name = "watchdog-${version}";
    version = "0.8.3";

    propagatedBuildInputs = with self; [ argh pathtools pyyaml ];

    buildInputs = stdenv.lib.optionals stdenv.isDarwin
      [ pkgs.darwin.apple_sdk.frameworks.CoreServices pkgs.darwin.cf-private ];

    doCheck = false;

    src = pkgs.fetchurl {
      url = "mirror://pypi/w/watchdog/${name}.tar.gz";
      sha256 = "0qj1vqszxwfx6d1s66s96jmfmy2j94bywxiqdydh6ikpvcm8hrby";
    };

    meta = {
      description = "Python API and shell utilities to monitor file system events";
      homepage = https://github.com/gorakhargosh/watchdog;
      license = licenses.asl20;
      maintainers = with maintainers; [ goibhniu ];
    };
  };

  pywatchman = buildPythonPackage rec {
    name = "pywatchman-${version}";
    version = "1.3.0";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pywatchman/pywatchman-${version}.tar.gz";
      sha256 = "c3d5be183b5b04f6ad575fc71b06dd196185dea1558d9f4d0598ba9beaab8245";
    };
    postPatch = ''
      substituteInPlace pywatchman/__init__.py \
        --replace "'watchman'" "'${pkgs.watchman}/bin/watchman'"
    '';
    # SyntaxError
    disabled = isPy3k;
    # No tests in archive
    doCheck = false;

  };

  zope_deprecation = buildPythonPackage rec {
    name = "zope.deprecation-4.1.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/z/zope.deprecation/${name}.tar.gz";
      sha256 = "fed622b51ffc600c13cc5a5b6916b8514c115f34f7ea2730409f30c061eb0b78";
    };

    buildInputs = with self; [ zope_testing ];

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };

  validictory = buildPythonPackage rec {
    name = "validictory-1.0.0a2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/v/validictory/validictory-1.0.0a2.tar.gz";
      sha256 = "c02388a70f5b854e71e2e09bd6d762a2d8c2a017557562e866d8ffafb0934b07";
    };

    doCheck = false;

    meta = {
      description = "Validate dicts against a schema";
      homepage = https://github.com/sunlightlabs/validictory;
      license = licenses.mit;
    };
  };

  vcrpy = callPackage ../development/python-modules/vcrpy { };

  venusian = buildPythonPackage rec {
    name = "venusian-1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/v/venusian/${name}.tar.gz";
      sha256 = "1720cff2ca9c369c840c1d685a7c7a21da1afa687bfe62edd93cae4bf429ca5a";
    };

    # TODO: https://github.com/Pylons/venusian/issues/23
    doCheck = false;

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };


  chameleon = buildPythonPackage rec {
    name = "Chameleon-2.25";

    src = pkgs.fetchurl {
      url = "mirror://pypi/C/Chameleon/${name}.tar.gz";
      sha256 = "0va95cml7wfjpvgj3dc9xdn8psyjh3zbk6v51b0hcqv2fzh409vb";
    } ;

    buildInputs = with self; [] ++ optionals isPy26 [ ordereddict unittest2 ];

    meta = {
       maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.all;
    };
  };

  ddt = buildPythonPackage (rec {
    name = "ddt-1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/ddt/${name}.tar.gz";
      sha256 = "e24ecb7e2cf0bf43fa9d4255d3ae2bd0b7ce30b1d1b89ace7aa68aca1152f37a";
    };

    meta = {
      description = "Data-Driven/Decorated Tests, a library to multiply test cases";

      homepage = https://github.com/txels/ddt;

      license = licenses.mit;
    };
  });

  descartes = callPackage ../development/python-modules/descartes { };

  distutils_extra = buildPythonPackage rec {
    name = "distutils-extra-${version}";
    version = "2.39";

    src = pkgs.fetchurl {
      url = "http://launchpad.net/python-distutils-extra/trunk/${version}/+download/python-${name}.tar.gz";
      sha256 = "1bv3h2p9ffbzyddhi5sccsfwrm3i6yxzn0m06fdxkj2zsvs28gvj";
    };

    meta = {
      homepage = https://launchpad.net/python-distutils-extra;
      description = "Enhancements to Python's distutils";
      license = licenses.gpl2;
    };
  };

  pyxdg = buildPythonPackage rec {
    name = "pyxdg-0.25";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyxdg/${name}.tar.gz";
      sha256 = "81e883e0b9517d624e8b0499eb267b82a815c0b7146d5269f364988ae031279d";
    };

    # error: invalid command 'test'
    doCheck = false;

    meta = {
      homepage = http://freedesktop.org/wiki/Software/pyxdg;
      description = "Contains implementations of freedesktop.org standards";
      license = licenses.lgpl2;
      maintainers = with maintainers; [ domenkozar ];
    };
  };

  chardet = callPackage ../development/python-modules/chardet { };

  crayons = callPackage ../development/python-modules/crayons{ };

  django = self.django_1_11;

  django_1_11 = callPackage ../development/python-modules/django/1_11.nix {
    gdal = self.gdal;
  };

  django_2_0 = callPackage ../development/python-modules/django/2_0.nix {
    gdal = self.gdal;
  };

  django_1_8 = buildPythonPackage rec {
    name = "Django-${version}";
    version = "1.8.18";
    disabled = pythonOlder "2.7";

    src = pkgs.fetchurl {
      url = "http://www.djangoproject.com/m/releases/1.8/${name}.tar.gz";
      sha256 = "1ishvbihr9pain0486qafb18dnb7v2ppq34nnx1s8f95bvfiqqf7";
    };

    # too complicated to setup
    doCheck = false;

    # patch only $out/bin to avoid problems with starter templates (see #3134)
    postFixup = ''
      wrapPythonProgramsIn $out/bin "$out $pythonPath"
    '';

    meta = {
      description = "A high-level Python Web framework";
      homepage = https://www.djangoproject.com/;
    };
  };

  django_appconf = callPackage ../development/python-modules/django_appconf { };

  django_colorful = buildPythonPackage rec {
    name = "django-colorful-${version}";
    version = "1.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-colorful/${name}.tar.gz";
      sha256 = "0y34hzvfrm1xbxrd8frybc9yzgqvz4c07frafipjikw7kfjsw8az";
    };

    # Tests aren't run
    doCheck = false;

    # Requires Django >= 1.8
    buildInputs = with self; [ django ];

    meta = {
      description = "Django extension that provides database and form color fields";
      homepage = https://github.com/charettes/django-colorful;
      license = licenses.mit;
    };
  };

  django_compressor = callPackage ../development/python-modules/django_compressor { };

  django_compat = callPackage ../development/python-modules/django-compat { };

  django_environ = buildPythonPackage rec {
    name = "django-environ-${version}";
    version = "0.4.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-environ/${name}.tar.gz";
      sha256 = "0i32vsgk1xmwpi7i6f6v5hg653y9dl0fsz5qmv94skz6hwgm5kvh";
    };

    # The testsuite fails to modify the base environment
    doCheck = false;
    propagatedBuildInputs = with self ; [ django six ];

    meta = {
      description = "Utilize environment variables to configure your Django application";
      homepage = https://github.com/joke2k/django-environ/;
      license = licenses.mit;
    };
  };

  django_evolution = buildPythonPackage rec {
    name = "django_evolution-0.7.5";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django_evolution/${name}.tar.gz";
      sha256 = "1qbcx54hq8iy3n2n6cki3bka1m9rp39np4hqddrm9knc954fb7nv";
    };

    propagatedBuildInputs = with self; [ django ];

    meta = {
      description = "A database schema evolution tool for the Django web framework";
      homepage = http://code.google.com/p/django-evolution/;
    };
  };

  django_extensions = callPackage ../development/python-modules/django-extensions { };

  django_guardian = callPackage ../development/python-modules/django_guardian { };

  django-ipware = callPackage ../development/python-modules/django-ipware { };

  django-jinja = callPackage ../development/python-modules/django-jinja2 { };

  django-pglocks = callPackage ../development/python-modules/django-pglocks { };

  django-picklefield = callPackage ../development/python-modules/django-picklefield { };

  django_polymorphic = callPackage ../development/python-modules/django-polymorphic { };

  django-sampledatahelper = callPackage ../development/python-modules/django-sampledatahelper { };

  django-sites = callPackage ../development/python-modules/django-sites { };

  django-sr = callPackage ../development/python-modules/django-sr { };

  django_tagging = callPackage ../development/python-modules/django_tagging { };

  django_tagging_0_4_3 = if
       self.django != self.django_1_8
  then throw "django_tagging_0_4_3 should be build with django_1_8"
  else (callPackage ../development/python-modules/django_tagging {}).overrideAttrs (attrs: rec {
    name = "django-tagging-0.4.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-tagging/${name}.tar.gz";
      sha256 = "0617azpmp6jpg3d88v2ir97qrc9aqcs2s9gyvv9bgf2cp55khxhs";
    };
    propagatedBuildInputs = with self; [ django ];
  });

  django_classytags = buildPythonPackage rec {
    name = "django-classy-tags-${version}";
    version = "0.6.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-classy-tags/${name}.tar.gz";
      sha256 = "0wxvpmjdzk0aajk33y4himn3wqjx7k0aqlka9j8ay3yfav78bdq0";
    };

    propagatedBuildInputs = with self; [ django ];

    # tests appear to be broken on 0.6.1 at least
    doCheck = ( version != "0.6.1" );

    meta = {
      description = "Class based template tags for Django";
      homepage = https://github.com/ojii/django-classy-tags;
      license = licenses.bsd3;
    };
  };

  # This package may need an older version of Django.
  # Override the package set and set e.g. `django = super.django_1_9`.
  # See the Nixpkgs manual for examples on how to override the package set.
  django_hijack = callPackage ../development/python-modules/django-hijack { };

  django_hijack_admin = callPackage ../development/python-modules/django-hijack-admin { };

  django_nose = buildPythonPackage rec {
    name = "django-nose-${version}";
    version = "1.4.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-nose/${name}.tar.gz";
      sha256 = "1fm47fkza2lk0xgc6qpi9vs78zg7q8cgl6mdan69sbycgy909ff0";
    };

    # vast dependency list
    doCheck = false;

    propagatedBuildInputs = with self; [ django nose ];

    meta = {
      description = "Provides all the goodness of nose in your Django tests";
      homepage = https://github.com/django-nose/django-nose;
      license = licenses.bsd3;
    };
  };

  django_modelcluster = buildPythonPackage rec {
    name = "django-modelcluster-${version}";
    version = "0.6.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-modelcluster/django-modelcluster-${version}.tar.gz";
      sha256 = "1plsdi44dvsj2sfx79lsrccjfg0ymajcsf5n0mln4cwd4qi5mwpx";
    };

    doCheck = false;

    propagatedBuildInputs = with self; [ pytz six ];

    meta = {
      description = "Django extension to allow working with 'clusters' of models as a single unit, independently of the database";
      homepage = https://github.com/torchbox/django-modelcluster/;
      license = licenses.bsd2;
      maintainers = with maintainers; [ desiderius ];
    };
  };

  djangorestframework = callPackage ../development/python-modules/djangorestframework { };

  django-raster = callPackage ../development/python-modules/django-raster { };

  django_redis = callPackage ../development/python-modules/django_redis { };

  django_reversion = buildPythonPackage rec {
    name = "django-reversion-${version}";
    version = "1.10.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-reversion/${name}.tar.gz";
      sha256 = "01iv8w6lmmq98qjhxmnp8ddjxifmhxcmp612ijd91wc8nv8lk12w";
    };

    propagatedBuildInputs = with self; [ django ] ++
      (optionals (pythonOlder "2.7") [ importlib ordereddict ]);

    meta = {
      description = "An extension to the Django web framework that provides comprehensive version control facilities";
      homepage = https://github.com/etianen/django-reversion;
      license = licenses.bsd3;
    };
  };

  django_silk = buildPythonPackage rec {
    name = "django-silk-${version}";
    version = "0.5.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-silk/${name}.tar.gz";
      sha256 = "845abc688738858ce06e993c4b7dbbcfcecf33029e828f143463ff96f9a78947";
    };

    doCheck = false;

    buildInputs = [ self.mock ];

    propagatedBuildInputs = with self; [
      django
      pygments
      simplejson
      dateutil
      requests
      sqlparse
      jinja2
      autopep8
      pytz
      pillow
    ];

    meta = {
      description = "Silky smooth profiling for the Django Framework";
      homepage = https://github.com/mtford90/silk;
      license = licenses.mit;
    };
  };

  django_taggit = buildPythonPackage rec {
    name = "django-taggit-${version}";
    version = "0.17.0";
    disabled = pythonOlder "2.7";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-taggit/django-taggit-${version}.tar.gz";
      sha256 = "1xy4mm1y6z6bpakw907859wz7fiw7jfm586dj89w0ggdqlb0767b";
    };

    doCheck = false;

    meta = {
      description = "django-taggit is a reusable Django application for simple tagging";
      homepage = https://github.com/alex/django-taggit/tree/master/;
      license = licenses.bsd2;
      maintainers = with maintainers; [ desiderius ];
    };
  };

  django_treebeard = buildPythonPackage rec {
    name = "django-treebeard-${version}";
    version = "3.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-treebeard/${name}.tar.gz";
      sha256 = "10p9rb2m1zccszg7590fjd0in6rabzsh86f5m7qm369mapc3b6dc";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ django ];

    meta = {
      description = "Efficient tree implementations for Django 1.6+";
      homepage = https://tabo.pe/projects/django-treebeard/;
      maintainers = with maintainers; [ desiderius ];
      license = licenses.asl20;
    };
  };

  django_pipeline = buildPythonPackage rec {
    name = "django-pipeline-${version}";
    version = "1.5.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-pipeline/${name}.tar.gz";
      sha256 = "1y49fa8jj7x9qjj5wzhns3zxwj0s73sggvkrv660cqw5qb7d8hha";
    };

    propagatedBuildInputs = with self; [ django futures ];

    meta = with stdenv.lib; {
      description = "Pipeline is an asset packaging library for Django";
      homepage = https://github.com/cyberdelia/django-pipeline;
      license = stdenv.lib.licenses.mit;
    };
  };

  django_pipeline_1_3 = self.django_pipeline.overrideDerivation (super: rec {
    name = "django-pipeline-1.3.27";
    src = pkgs.fetchurl {
      url = "mirror://pypi/d/django-pipeline/${name}.tar.gz";
      sha256 = "0iva3cmnh5jw54c7w83nx9nqv523hjvkbjchzd2pb6vzilxf557k";
    };
  });


  djblets = if (versionOlder self.django.version "1.6.11") ||
               (versionAtLeast self.django.version "1.9")
            then throw "djblets only suported for Django<1.8.999,>=1.6.11"
            else buildPythonPackage rec {
    name = "Djblets-0.9";

    src = pkgs.fetchurl {
      url = "http://downloads.reviewboard.org/releases/Djblets/0.9/${name}.tar.gz";
      sha256 = "1rr5vjwiiw3kih4k9nawislf701l838dbk5xgizadvwp6lpbpdpl";
    };

    propagatedBuildInputs = with self; [
      django feedparser django_pipeline_1_3 pillowfight pytz ];

    meta = {
      description = "A collection of useful extensions for Django";
      homepage = https://github.com/djblets/djblets;
    };
  };

  dj-database-url = callPackage ../development/python-modules/dj-database-url { };

  djmail = callPackage ../development/python-modules/djmail { };

  pillowfight = buildPythonPackage rec {
    name = "pillowfight-${version}";
    version = "0.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pillowfight/pillowfight-${version}.tar.gz";
      sha256 = "1mh1nhcjjgv7x134sv0krri59ng8bp2w6cwsxc698rixba9f3g0m";
    };

    propagatedBuildInputs = with self; [
      pillow
    ];
    meta = with stdenv.lib; {
      description = "Pillow Fight";
      homepage = "https://github.com/beanbaginc/pillowfight";
    };
  };

  kaptan = buildPythonPackage rec {
    name = "kaptan-${version}";
    version = "0.5.8";

    src = pkgs.fetchurl {
      url = "mirror://pypi/k/kaptan/${name}.tar.gz";
      sha256 = "1b8r86yyvdvyxd6f10mhkl6cr2jhxm80jjqr4zch96w9hs9rh5vq";
    };

    propagatedBuildInputs = with self; [ pyyaml ];

    meta = with stdenv.lib; {
      description = "Configuration manager for python applications";
      homepage = https://emre.github.io/kaptan/;
      license = licenses.bsd3;
      platforms = platforms.linux;
      maintainers = with maintainers; [ jgeerds ];
    };
  };

  keepalive = buildPythonPackage rec {
    name = "keepalive-${version}";
    version = "0.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/k/keepalive/keepalive-${version}.tar.gz";
      sha256 = "3c6b96f9062a5a76022f0c9d41e9ef5552d80b1cadd4fccc1bf8f183ba1d1ec1";
    };

    # No tests included
    doCheck = false;

    meta = with stdenv.lib; {
      description = "An HTTP handler for `urllib2` that supports HTTP 1.1 and keepalive";
      homepage = "https://github.com/wikier/keepalive";
    };
  };


  SPARQLWrapper = buildPythonPackage rec {
    name = "SPARQLWrapper-${version}";
    version = "1.7.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/S/SPARQLWrapper/SPARQLWrapper-${version}.tar.gz";
      sha256 = "1y12hpsfjd779yi29bhvl6g4vszadjvd8jw38z5rg77b034vxjnw";
    };

    # break circular dependency loop
    patchPhase = ''
      sed -i '/rdflib/d' requirements.txt
    '';

    # Doesn't actually run tests
    doCheck = false;

    propagatedBuildInputs = with self; [
      six isodate pyparsing html5lib keepalive
    ];

    meta = with stdenv.lib; {
      description = "This is a wrapper around a SPARQL service. It helps in creating the query URI and, possibly, convert the result into a more manageable format";
      homepage = "http://rdflib.github.io/sparqlwrapper";
    };
  };

  dulwich = callPackage ../development/python-modules/dulwich {
    inherit (pkgs) git glibcLocales;
  };

  hg-git = buildPythonPackage rec {
    name = "hg-git-${version}";
    version = "0.8.11";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hg-git/${name}.tar.gz";
      sha256 = "08kw1sj3sq1q1571hwkc51w20ks9ysmlg93pcnmd6gr66bz02dyn";
    };

    propagatedBuildInputs = with self; [ dulwich ];

    meta = {
      description = "Push and pull from a Git server using Mercurial";
      homepage = http://hg-git.github.com/;
      maintainers = with maintainers; [ koral ];
      license = stdenv.lib.licenses.gpl2;
    };
  };


  docutils = buildPythonPackage rec {
    name = "docutils-${version}";
    version = "0.14";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/docutils/${name}.tar.gz";
      sha256 = "0x22fs3pdmr42kvz6c654756wja305qv6cx1zbhwlagvxgr4xrji";
    };

    checkPhase = if isPy3k then ''
      ${python.interpreter} test3/alltests.py
    '' else ''
      ${python.interpreter} test/alltests.py
    '';

    # Create symlinks lacking a ".py" suffix, many programs depend on these names
    postFixup = ''
      (cd $out/bin && for f in *.py; do
        ln -s $f $(echo $f | sed -e 's/\.py$//')
      done)
    '';

    meta = {
      description = "An open-source text processing system for processing plaintext documentation into useful formats, such as HTML or LaTeX";
      homepage = http://docutils.sourceforge.net/;
      maintainers = with maintainers; [ garbas AndersonTorres ];
    };
  };


  dtopt = buildPythonPackage rec {
    name = "dtopt-0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/d/dtopt/${name}.tar.gz";
      sha256 = "06ae07a12294a7ba708abaa63f838017d1a2faf6147a1e7a14ca4fa28f86da7f";
    };

    meta = {
      description = "Add options to doctest examples while they are running";
      homepage = https://pypi.python.org/pypi/dtopt;
    };
    # Test contain Python 2 print
    disabled = isPy3k;
  };


  ecdsa = buildPythonPackage rec {
    name = "ecdsa-${version}";
    version = "0.13";

    src = pkgs.fetchurl {
      url = "mirror://pypi/e/ecdsa/${name}.tar.gz";
      sha256 = "1yj31j0asmrx4an9xvsaj2icdmzy6pw0glfpqrrkrphwdpi1xkv4";
    };

    # Only needed for tests
    buildInputs = with self; [ pkgs.openssl ];

    meta = {
      description = "ECDSA cryptographic signature library";
      homepage = "https://github.com/warner/python-ecdsa";
      license = licenses.mit;
      maintainers = with maintainers; [ aszlig ];
    };
  };


  elpy = buildPythonPackage rec {
    name = "elpy-${version}";
    version = "1.9.0";
    src = pkgs.fetchurl {
      url = "mirror://pypi/e/elpy/${name}.tar.gz";
      sha256 = "419f7b05b19182bc1aedde1ae80812c1534e59a0493476aa01ea819e76ba26f0";
    };
    python2Deps = if isPy3k then [ ] else [ self.rope ];
    propagatedBuildInputs = with self; [ flake8 autopep8 jedi importmagic ] ++ python2Deps;

    doCheck = false; # there are no tests

    meta = {
      description = "Backend for the elpy Emacs mode";
      homepage = "https://github.com/jorgenschaefer/elpy";
    };
  };


  enum = buildPythonPackage rec {
    name = "enum-0.4.4";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/e/enum/${name}.tar.gz";
      sha256 = "9bdfacf543baf2350df7613eb37f598a802f346985ca0dc1548be6494140fdff";
    };

    doCheck = !isPyPy;

    buildInputs = with self; [ ];

    propagatedBuildInputs = with self; [ ];

    meta = {
      homepage = https://pypi.python.org/pypi/enum/;
      description = "Robust enumerated type support in Python";
    };
  };

  enum-compat = callPackage ../development/python-modules/enum-compat { };

  enum34 = if pythonAtLeast "3.4" then null else buildPythonPackage rec {
    pname = "enum34";
    version = "1.1.6";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1";
    };

    buildInputs = optional isPy26 self.ordereddict;
    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';


    meta = {
      homepage = https://pypi.python.org/pypi/enum34;
      description = "Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4";
      license = "BSD";
    };
  };

  epc = buildPythonPackage rec {
    name = "epc-0.0.3";
    src = pkgs.fetchurl {
      url = "mirror://pypi/e/epc/${name}.tar.gz";
      sha256 = "30b594bd4a4acbd5bda0d3fa3d25b4e8117f2ff8f24d2d1e3e36c90374f3c55e";
    };

    propagatedBuildInputs = with self; [ sexpdata ];
    doCheck = false;

    meta = {
      description = "EPC (RPC stack for Emacs Lisp) implementation in Python";
      homepage = "https://github.com/tkf/python-epc";
    };
  };

  et_xmlfile = buildPythonPackage rec {
    version = "1.0.1";
    name = "et_xmlfile-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/e/et_xmlfile/${name}.tar.gz";
      sha256="0nrkhcb6jdrlb6pwkvd4rycw34y3s931hjf409ij9xkjsli9fkb1";
    };

    buildInputs = with self; [ lxml pytest ];
    checkPhase = ''
      py.test $out
    '';

    meta = {
      description = "An implementation of lxml.xmlfile for the standard library";
      longDescription = ''
        et_xmlfile is a low memory library for creating large XML files.

        It is based upon the xmlfile module from lxml with the aim of allowing
        code to be developed that will work with both libraries. It was developed
        initially for the openpyxl project but is now a standalone module.

        The code was written by Elias Rabel as part of the Python Düsseldorf
        openpyxl sprint in September 2014.
      '';
      homepage = "https://pypi.python.org/pypi/et_xmlfile";
      license = licenses.mit;
      maintainers = with maintainers; [ sjourdois ];
    };
  };

  eventlet = buildPythonPackage rec {
    pname = "eventlet";
    version = "0.20.0";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "15bq5ybbigxnp5xwkps53zyhlg15lmcnq3ny2dppj0r0bylcs5rf";
    };

    buildInputs = with self; [ nose httplib2 pyopenssl  ];

    doCheck = false;  # too much transient errors to bother

    propagatedBuildInputs = optionals (!isPyPy) [ self.greenlet ] ++
      (with self; [ enum-compat ]) ;

    meta = {
      homepage = https://pypi.python.org/pypi/eventlet/;
      description = "A concurrent networking library for Python";
    };
  };

  exifread = buildPythonPackage rec {
    name = "ExifRead-2.1.2";

    meta = {
      description = "Easy to use Python module to extract Exif metadata from tiff and jpeg files";
      homepage    = "https://github.com/ianare/exif-py";
      license     = "BSD";
      maintainers = with maintainers; [ vozz ];
    };

    src = pkgs.fetchurl {
      url = "mirror://pypi/E/ExifRead/${name}.tar.gz";
      sha256 = "1b90jf6m9vxh9nanhpyvqdq7hmfx5iggw1l8kq10jrs6xgr49qkr";
    };
  };

  fastimport = callPackage ../development/python-modules/fastimport { };

  fastrlock = callPackage ../development/python-modules/fastrlock {};

  feedgen = callPackage ../development/python-modules/feedgen { };

  feedgenerator = callPackage ../development/python-modules/feedgenerator {
    inherit (pkgs) glibcLocales;
  };

  feedparser = buildPythonPackage (rec {
    name = "feedparser-5.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/feedparser/${name}.tar.gz";
      sha256 = "1ycva69bqssalhqg45rbrfipz3l6hmycszy26k0351fhq990c0xx";
    };

    # lots of networking failures
    doCheck = false;

    meta = {
      homepage = http://code.google.com/p/feedparser/;
      description = "Universal feed parser";
      license = licenses.bsd2;
      maintainers = with maintainers; [ domenkozar ];
    };
  });

  pyfribidi = buildPythonPackage rec {
    version = "0.11.0";
    name = "pyfribidi-${version}";
    disabled = isPy3k || isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyfribidi/${name}.zip";
      sha256 = "6f7d83c09eae0cb98a40b85ba3dedc31af4dbff8fc4425f244c1e9f44392fded";
    };

    meta = {
      description = "A simple wrapper around fribidi";
      homepage = https://github.com/pediapress/pyfribidi;
      license = stdenv.lib.licenses.gpl2;
    };
  };

  docker_compose = callPackage ../development/python-modules/docker_compose {};

  fdroidserver = buildPythonPackage rec {
    version = "2016-05-31";
    name = "fdroidserver-git-${version}";

    disabled = ! isPy3k;

    src = pkgs.fetchFromGitLab {
      owner = "fdroid";
      repo = "fdroidserver";
      rev = "401649e0365e6e365fc48ae8a3af94768af865f3";
      sha256 = "1mmi2ffpym1qw694yj938kc7b4xhq0blri7wkjaqddcyykjyr94d";
    };

    propagatedBuildInputs = with self; [ libcloud pyyaml paramiko pyasn1 pyasn1-modules pillow mwclient GitPython ];

    meta = {
      homepage = https://f-droid.org;
      description = "Server and tools for F-Droid, the Free Software repository system for Android";
      maintainers = with maintainers; [ ];
      license = licenses.agpl3;
    };
  };

  filebrowser_safe = buildPythonPackage rec {
    version = "0.3.6";
    name = "filebrowser_safe-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/filebrowser_safe/${name}.tar.gz";
      sha256 = "02bn60fdslvng2ckn65fms3hjbzgsa8qa5161a8lr720wbx8gpj2";
    };

    buildInputs = [ self.django ];

    # There is no test embedded
    doCheck = false;

    meta = {
      description = "A snapshot of django-filebrowser for the Mezzanine CMS";
      longDescription = ''
        filebrowser_safe was created to provide a snapshot of the FileBrowser
        asset manager for Django, to be referenced as a dependency for the
        Mezzanine CMS for Django.

        At the time of filebrowser_safe's creation, FileBrowser was incorrectly
        packaged on PyPI, and had also dropped compatibility with Django 1.1 -
        filebrowser_safe was therefore created to address these specific
        issues.
      '';
      homepage = https://github.com/stephenmcd/filebrowser-safe;
      downloadPage = https://pypi.python.org/pypi/filebrowser_safe/;
      license = licenses.free;
      maintainers = with maintainers; [ prikhi ];
      platforms = platforms.linux;
    };
  };

  pycodestyle = callPackage ../development/python-modules/pycodestyle { };

  filebytes = buildPythonPackage rec {
    name = "filebytes-0.9.12";
    src = pkgs.fetchurl {
      url = "mirror://pypi/f/filebytes/${name}.tar.gz";
      sha256 = "6cd1c4ca823f6541c963a317e55382609789802dedad08209f4d038369e3f0ac";
    };
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "https://scoding.de/filebytes-introduction";
      license = licenses.gpl2;
      description = "Scripts to parse ELF, PE, Mach-O and OAT (Android Runtime)";
      maintainers = with maintainers; [ bennofs ];
    };
  };

  filelock = callPackage ../development/python-modules/filelock {};

  fiona = callPackage ../development/python-modules/fiona { gdal = pkgs.gdal; };

  flake8 = callPackage ../development/python-modules/flake8 { };

  flake8-blind-except = callPackage ../development/python-modules/flake8-blind-except { };

  flake8-debugger = callPackage ../development/python-modules/flake8-debugger { };

  flake8-future-import = callPackage ../development/python-modules/flake8-future-import { };

  flake8-import-order = callPackage ../development/python-modules/flake8-import-order { };

  flaky = buildPythonPackage rec {
    name = "flaky-${version}";
    version = "3.1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/flaky/${name}.tar.gz";
      sha256 = "1x9ixika7wqjj52x8wnsh1vk7jadkdqpx01plj7mlh8slwyq4s41";
    };

    buildInputs = with self; [ mock pytest ];

    # waiting for feedback https://github.com/box/flaky/issues/97
    doCheck = false;

    meta = {
      homepage = https://github.com/box/flaky;
      description = "Plugin for nose or py.test that automatically reruns flaky tests";
      license = licenses.asl20;
    };
  };

  flask = callPackage ../development/python-modules/flask { };

  flask_assets = callPackage ../development/python-modules/flask-assets { };

  flask_cache = buildPythonPackage rec {
    name = "Flask-Cache-0.13.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/F/Flask-Cache/${name}.tar.gz";
      sha256 = "90126ca9bc063854ef8ee276e95d38b2b4ec8e45fd77d5751d37971ee27c7ef4";
    };

    propagatedBuildInputs = with self; [ werkzeug flask ];

    meta = {
      homepage = https://github.com/thadeusb/flask-cache;
      description = "Adds cache support to your Flask application";
      license = "BSD";
    };
  };

  flask-common = callPackage ../development/python-modules/flask-common { };

  flask-compress = callPackage ../development/python-modules/flask-compress { };

  flask-cors = callPackage ../development/python-modules/flask-cors { };

  flask_elastic = callPackage ../development/python-modules/flask-elastic { };

  flask-limiter = callPackage ../development/python-modules/flask-limiter { };

  flask_login = callPackage ../development/python-modules/flask-login { };

  flask_ldap_login = callPackage ../development/python-modules/flask-ldap-login { };

  flask_mail = callPackage ../development/python-modules/flask-mail { };

  flask_marshmallow = callPackage ../development/python-modules/flask-marshmallow { };

  flask_migrate = callPackage ../development/python-modules/flask-migrate { };

  flask_oauthlib = callPackage ../development/python-modules/flask-oauthlib { };

  flask_principal = callPackage ../development/python-modules/flask-principal { };

  flask-pymongo = callPackage ../development/python-modules/Flask-PyMongo { };

  flask-restful = callPackage ../development/python-modules/flask-restful { };

  flask-restplus = callPackage ../development/python-modules/flask-restplus { };

  flask_script = callPackage ../development/python-modules/flask-script { };

  flask_sqlalchemy = buildPythonPackage rec {
    name = "Flask-SQLAlchemy-${version}";
    version = "2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/F/Flask-SQLAlchemy/${name}.tar.gz";
      sha256 = "1i9ps5d5snih9xlqhrvmi3qfiygkmqzxh92n25kj4pf89kj4s965";
    };

    propagatedBuildInputs = with self ; [ flask sqlalchemy ];

    meta = {
      description = "SQLAlchemy extension for Flask";
      homepage = http://flask-sqlalchemy.pocoo.org/;
      license = licenses.bsd3;
    };
  };

  flask_testing = callPackage ../development/python-modules/flask-testing { };

  flask_wtf = callPackage ../development/python-modules/flask-wtf { };

  wtforms = buildPythonPackage rec {
    version = "2.1";
    name = "wtforms-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/W/WTForms/WTForms-${version}.zip";
      sha256 = "0vyl26y9cg409cfyj8rhqxazsdnd0jipgjw06civhrd53yyi1pzz";
    };

    # Django tests are broken "django.core.exceptions.AppRegistryNotReady: Apps aren't loaded yet."
    # This is fixed in master I believe but not yet in 2.1;
    doCheck = false;

    propagatedBuildInputs = with self; ([ Babel ] ++ (optionals isPy26 [ ordereddict ]));

    meta = {
      homepage = https://github.com/wtforms/wtforms;
      description = "A flexible forms validation and rendering library for Python";
      license = licenses.bsd3;
    };
  };

  # py3k disabled, see https://travis-ci.org/NixOS/nixpkgs/builds/48759067
  graph-tool = if isPy3k then throw "graph-tool in Nix doesn't support py3k yet"
    else callPackage ../development/python-modules/graph-tool/2.x.x.nix { boost = pkgs.boost159; };

  grappelli_safe = buildPythonPackage rec {
    version = "0.3.13";
    name = "grappelli_safe-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/grappelli_safe/${name}.tar.gz";
      sha256 = "8b21b4724bce449cc4f22dc74ed0be9b3e841d968f3271850bf4836864304eb6";
    };

    meta = {
      description = "A snapshot of django-grappelli for the Mezzanine CMS";
      longDescription = ''
        grappelli_safe was created to provide a snapshot of the Grappelli admin
        skin for Django, to be referenced as a dependency for the Mezzanine CMS
        for Django.

        At the time of grappelli_safe's creation, Grappelli was incorrectly
        packaged on PyPI, and had also dropped compatibility with Django 1.1 -
        grappelli_safe was therefore created to address these specific issues.
      '';
      homepage = https://github.com/stephenmcd/grappelli-safe;
      downloadPage = http://pypi.python.org/pypi/grappelli_safe/;
      license = licenses.free;
      maintainers = with maintainers; [ prikhi ];
      platforms = platforms.linux;
    };
  };

  pytorch = callPackage ../development/python-modules/pytorch { };

  python2-pythondialog = buildPythonPackage rec {
    name = "python2-pythondialog-${version}";
    version = "3.3.0";
    disabled = !isPy27;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python2-pythondialog/python2-pythondialog-${version}.tar.gz";
      sha256 = "1yhkagsh99bfi592ymczf8rnw8rk6n9hdqy3dd98m3yrx8zmjvry";
    };

    patchPhase = ''
      substituteInPlace dialog.py --replace ":/bin:/usr/bin" ":$out/bin"
    '';

    meta = with stdenv.lib; {
      homepage = "http://pythondialog.sourceforge.net/";
    };
  };

  pyRFC3339 = buildPythonPackage rec {
    name = "pyRFC3339-${version}";
    version = "0.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyRFC3339/pyRFC3339-${version}.tar.gz";
      sha256 = "1pp648xsjaw9h1xq2mgwzda5wis2ypjmzxlksc1a8grnrdmzy155";
    };

    propagatedBuildInputs = with self; [ pytz ];
    buildInputs = with self; [ nose ];
  };

  ConfigArgParse = callPackage ../development/python-modules/configargparse { };

  jsonschema = callPackage ../development/python-modules/jsonschema { };

  vcversioner = callPackage ../development/python-modules/vcversioner { };

  falcon = buildPythonPackage (rec {
    name = "falcon-1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/falcon/${name}.tar.gz";
      sha256 = "ddce23a2dd0abba6d19775e9bf7ba64e184b15a0e7163e65f62af63354193f63";
    };

    buildInputs = with self; stdenv.lib.optionals doCheck [coverage ddt nose pyyaml requests testtools];
    propagatedBuildInputs = with self; [ six python_mimeparse ];

    # The travis build fails since the migration from multiprocessing to threading for hosting the API under test.
    # OSError: [Errno 98] Address already in use
    doCheck = false;

    meta = {
      description = "An unladen web framework for building APIs and app backends";
      homepage = http://falconframework.org;
      license = licenses.asl20;
      maintainers = with maintainers; [ desiderius ];
    };
  });
  hug = buildPythonPackage rec {
    name = "hug-2.1.2";
    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hug/${name}.tar.gz";
      sha256 = "93325e13706594933a9afb0d4f0b0748134494299038f07df41152baf6f89f4c";
    };
    disabled = !isPy3k;

    propagatedBuildInputs = with self; [ falcon requests ];

    # tests are not shipped in the tarball
    doCheck = false;

    meta = {
      description = "A Python framework that makes developing APIs as simple as possible, but no simpler";
      homepage = https://github.com/timothycrosley/hug;
      license = licenses.mit;
    };
  };
  flup = buildPythonPackage (rec {
    name = "flup-1.0.2";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "http://www.saddi.com/software/flup/dist/${name}.tar.gz";
      sha256 = "1nbx174g40l1z3a8arw72qz05a1qxi3didp9wm7kvkn1bxx33bab";
    };

    meta = {
      homepage = "http://trac.saddi.com/flup";
      description = "FastCGI Python module set";
    };
  });

  fn = callPackage ../development/python-modules/fn { };

  folium = callPackage ../development/python-modules/folium { };

  fontforge = toPythonModule (pkgs.fontforge.override {
    withPython = true;
    inherit python;
  });

  fonttools = callPackage ../development/python-modules/fonttools { };

  foolscap = buildPythonPackage (rec {
    name = "foolscap-${version}";
    version = "0.12.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/foolscap/${name}.tar.gz";
      sha256 = "1bpmqq6485mmr5jza9q2c55l9m1bfsvsbd9drsip7p5qcsi22jrz";
    };

    propagatedBuildInputs = with self; [ mock twisted pyopenssl service-identity ];

    checkPhase = ''
      # Either uncomment this, or remove this custom check phase entirely, if
      # you wish to do battle with the foolscap tests. ~ C.
      # trial foolscap
    '';

    meta = {
      homepage = http://foolscap.lothar.com/;

      description = "Foolscap, an RPC protocol for Python that follows the distributed object-capability model";

      longDescription = ''
        "Foolscap" is the name for the next-generation RPC protocol,
        intended to replace Perspective Broker (part of Twisted).
        Foolscap is a protocol to implement a distributed
        object-capabilities model in Python.
      '';

      # See http://foolscap.lothar.com/trac/browser/LICENSE.
      license = licenses.mit;

      maintainers = [ ];
    };
  });

  forbiddenfruit = buildPythonPackage rec {
    version = "0.1.0";
    name = "forbiddenfruit-${version}";

    src = pkgs.fetchurl {
      url= "mirror://pypi/f/forbiddenfruit/${name}.tar.gz";
      sha256 = "0xra2kw6m8ag29ifwmhi5zqksh4cr0yy1waqd488rm59kcr3zl79";
    };

    meta = {
      description = "Patch python built-in objects";
      homepage = https://pypi.python.org/pypi/forbiddenfruit;
      license = licenses.mit;
    };
  };

  fs = buildPythonPackage rec {
    name = "fs-0.5.4";

    src = pkgs.fetchurl {
      url    = "mirror://pypi/f/fs/${name}.tar.gz";
      sha256 = "ba2cca8773435a7c86059d57cb4b8ea30fda40f8610941f7822d1ce3ffd36197";
    };

    LC_ALL = "en_US.UTF-8";
    buildInputs = [ pkgs.glibcLocales ];
    propagatedBuildInputs = [ self.six ];

    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';

    # Because 2to3 is used the tests in $out need to be run.
    # Both when using unittest and pytest this resulted in many errors,
    # some Python byte/str errors, and others specific to resources tested.
    # Failing tests due to the latter is to be expected with this type of package.
    # Tests are therefore disabled.
    doCheck = false;

    meta = {
      description = "Filesystem abstraction";
      homepage    = http://pypi.python.org/pypi/fs;
      license     = licenses.bsd3;
      maintainers = with maintainers; [ lovek323 ];
      platforms   = platforms.unix;
    };
  };

  fuse = callPackage ../development/python-modules/python-fuse { fuse = pkgs.fuse; };

  fusepy = buildPythonPackage rec {
    name = "fusepy-2.0.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/fusepy/${name}.tar.gz";
      sha256 = "0v5grm4zyf58hsplwsxfbihddw95lz9w8cy3rpzbyha287swgx8h";
    };

    propagatedBuildInputs = [ pkgs.fuse ];

    # No tests included
    doCheck = false;

    patchPhase = ''
      substituteInPlace fuse.py --replace \
        "find_library('fuse')" "'${pkgs.fuse}/lib/libfuse.so'"
    '';

    meta = {
      description = "Simple ctypes bindings for FUSE";
      longDescription = ''
        Python module that provides a simple interface to FUSE and MacFUSE.
        It's just one file and is implemented using ctypes.
      '';
      homepage = https://github.com/terencehonles/fusepy;
      license = licenses.isc;
      platforms = platforms.unix;
    };
  };

  future = callPackage ../development/python-modules/future { };

  futures = buildPythonPackage rec {
    name = "futures-${version}";
    version = "3.1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/futures/${name}.tar.gz";
      sha256 = "1z9j05fdj2yszjmz4pmjhl2jdnwhdw80cjwfqq3ci0yx19gv9v2i";
    };

    # This module is for backporting functionality to Python 2.x, it's builtin in py3k
    disabled = isPy3k;

    checkPhase = ''
        ${python.interpreter} -m unittest discover
    '';

    # Tests fail
    doCheck = false;

    meta = with pkgs.stdenv.lib; {
      description = "Backport of the concurrent.futures package from Python 3.2";
      homepage = "https://github.com/agronholm/pythonfutures";
      license = licenses.bsd2;
      maintainers = with maintainers; [ garbas ];
    };
  };

  futures_2_2 = self.futures.override rec {
    version = "2.2.0";
    name = "futures-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/futures/${name}.tar.gz";
      sha256 = "1lqfzl3z3pkxakgbcrfy6x7x0fp3q18mj5lpz103ljj7fdqha70m";
    };
  };

  gcovr = buildPythonPackage rec {
    name = "gcovr-2.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gcovr/${name}.tar.gz";
      sha256 = "2c878e03c2eff2282e64035bec0a30532b2b1173aadf08486401883b79e4dab1";
    };

    meta = {
      description = "A Python script for summarizing gcov data";
      license = "BSD";
    };
  };

  gdal = toPythonModule (pkgs.gdal.override {
    pythonPackages = self;
  });

  gdrivefs = buildPythonPackage rec {
    version = "0.14.9";
    name = "gdrivefs-${version}";
    namePrefix = "";
    disabled = !isPy27;

    src = pkgs.fetchurl {
      url = "https://github.com/dsoprea/GDriveFS/archive/${version}.tar.gz";
      sha256 = "1mc2r35nf5k8vzwdcdhi0l9rb97amqd5xb53lhydj8v8f4rndk7a";
    };

    buildInputs = with self; [ gipc greenlet httplib2 six ];
    propagatedBuildInputs = with self; [ dateutil fusepy google_api_python_client ];

    patchPhase = ''
      substituteInPlace gdrivefs/resources/requirements.txt \
        --replace "==" ">="
    '';

    meta = {
      description = "Mount Google Drive as a local file system";
      longDescription = ''
        GDriveFS is a FUSE wrapper for Google Drive developed. Design goals:
        - Thread for monitoring changes via "changes" functionality of API.
        - Complete stat() implementation.
        - Seamlessly work around duplicate-file allowances in Google Drive.
        - Seamlessly manage file-type versatility in Google Drive
          (Google Doc files do not have a particular format).
        - Allow for the same file at multiple paths.
      '';
      homepage = https://github.com/dsoprea/GDriveFS;
      license = licenses.gpl2;
      platforms = platforms.unix;
    };
  };

  genshi = buildPythonPackage {
    name = "genshi-0.7";

    src = pkgs.fetchurl {
      url = http://ftp.edgewall.com/pub/genshi/Genshi-0.7.tar.gz;
      sha256 = "0lkkbp6fbwzv0zda5iqc21rr7rdldkwh3hfabfjl9i4bwq14858x";
    };

    # FAIL: test_sanitize_remove_script_elem (genshi.filters.tests.html.HTMLSanitizerTestCase)
    # FAIL: test_sanitize_remove_src_javascript (genshi.filters.tests.html.HTMLSanitizerTestCase)
    doCheck = false;

    buildInputs = with self; [ setuptools ];

    meta = {
      description = "Python components for parsing HTML, XML and other textual content";

      longDescription = ''
        Python library that provides an integrated set of
        components for parsing, generating, and processing HTML, XML or other
        textual content for output generation on the web.
      '';

      license = "BSD";
    };
  };

  gevent = callPackage ../development/python-modules/gevent { };

  geventhttpclient = buildPythonPackage rec {
    name = "geventhttpclient-${version}";
    version = "1.3.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/geventhttpclient/${name}.tar.gz";
      sha256 = "bd87af8854f5fb05738916c8973671f7035568aec69b7c842887d6faf9c0a01d";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ gevent certifi six backports_ssl_match_hostname ];

    # Several tests fail that require network
    doCheck = false;
    checkPhase = ''
      py.test $out
    '';

    meta = {
      homepage = https://github.com/gwik/geventhttpclient;
      description = "HTTP client library for gevent";
      license = licenses.mit;
      maintainers = with maintainers; [ koral ];
    };
  };

  gevent-socketio = buildPythonPackage rec {
    name = "gevent-socketio-0.3.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gevent-socketio/${name}.tar.gz";
      sha256 = "1zra86hg2l1jcpl9nsnqagy3nl3akws8bvrbpgdxk15x7ywllfak";
    };

    buildInputs = with self; [ versiontools gevent-websocket mock pytest ];
    propagatedBuildInputs = with self; [ gevent ];

  };

  geopandas = callPackage ../development/python-modules/geopandas { };

  gevent-websocket = buildPythonPackage rec {
    name = "gevent-websocket-0.9.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gevent-websocket/${name}.tar.gz";
      sha256 = "07rqwfpbv13mk6gg8mf0bmvcf6siyffjpgai1xd8ky7r801j4xb4";
    };

    # SyntaxError in tests.
    disabled = isPy3k;

    propagatedBuildInputs = with self; [ gevent ];

  };

  genzshcomp = buildPythonPackage {
    name = "genzshcomp-0.5.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/genzshcomp/genzshcomp-0.5.1.tar.gz";
      sha256 = "c77d007cc32cdff836ecf8df6192371767976c108a75b055e057bb6f4a09cd42";
    };

    buildInputs = with self; [ setuptools ] ++ (optional isPy26 argparse);

    meta = {
      description = "Automatically generated zsh completion function for Python's option parser modules";
      license = "BSD";
    };
  };


  gflags = callPackage ../development/python-modules/gflags { };

  ghdiff = callPackage ../development/python-modules/ghdiff { };

  gipc = buildPythonPackage rec {
    name = "gipc-0.5.0";
    disabled = !isPy26 && !isPy27;

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gipc/${name}.zip";
      sha256 = "08c35xzv7nr12d9xwlywlbyzzz2igy0yy6y52q2nrkmh5d4slbpc";
    };

    propagatedBuildInputs = with self; [ gevent ];

    meta = {
      description = "gevent-cooperative child processes and IPC";
      longDescription = ''
        Usage of Python's multiprocessing package in a gevent-powered
        application may raise problems and most likely breaks the application
        in various subtle ways. gipc (pronunciation "gipsy") is developed with
        the motivation to solve many of these issues transparently. With gipc,
        multiprocessing. Process-based child processes can safely be created
        anywhere within your gevent-powered application.
      '';
      homepage = http://gehrcke.de/gipc;
      license = licenses.mit;
    };
  };

  git-sweep = buildPythonPackage rec {
    name = "git-sweep-0.1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/git-sweep/${name}.tar.gz";
      sha256 = "1csp0zd049d643d409rfivbswwzrayb4i6gkypp5mc27fb1z2afd";
    };

    propagatedBuildInputs = with self; [ GitPython ];

    meta = {
      description = "A command-line tool that helps you clean up Git branches";
      homepage = https://github.com/arc90/git-sweep;
      license = licenses.mit;
      maintainers = with maintainers; [ pSub ];
    };
  };

  glances = buildPythonPackage rec {
    name = "glances-${version}";
    version = "2.11.1";
    disabled = isPyPy;

    src = pkgs.fetchFromGitHub {
      owner = "nicolargo";
      repo = "glances";
      rev = "v${version}";
      sha256 = "1n3x0bkydlqmxdr0wdgfgichp8fyldzkaijj618y5ns2k5qiwsxr";
    };

    doCheck = false;

    buildInputs = with self; [ unittest2 ];
    propagatedBuildInputs = with self; [ psutil setuptools bottle batinfo pkgs.hddtemp pysnmp ];

    preConfigure = ''
      sed -i 's/data_files\.append((conf_path/data_files.append(("etc\/glances"/' setup.py;
    '';

    meta = {
      homepage = "https://nicolargo.github.io/glances/";
      description = "Cross-platform curses-based monitoring tool";
      license = licenses.lgpl3;
      maintainers = with maintainers; [ primeos koral ];
    };
  };

  github3_py = buildPythonPackage rec {
    name = "github3.py-${version}";
    version = "1.0.0a4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/github3.py/${name}.tar.gz";
      sha256 = "0rhnrhb7qc60h82hkd4wnj1jh544yzrf4pjmn4rqacdi59p7f3jp";
    };

    buildInputs = with self; [ unittest2 pytest mock betamax betamax-matchers ];

    propagatedBuildInputs = with self; [ requests pyopenssl uritemplate_py
      ndg-httpsclient requests_toolbelt pyasn1 ];

    postPatch = ''
      sed -i -e 's/mock ==1.0.1/mock>=1.0.1/' setup.py
      sed -i -e 's/unittest2 ==0.5.1/unittest2>=0.5.1/' setup.py
    '';

    # TODO: only disable the tests that require network
    doCheck = false;

    meta = with stdenv.lib; {
      homepage = http://github3py.readthedocs.org/en/master/;
      description = "A wrapper for the GitHub API written in python";
      license = licenses.bsd3;
      maintainers = with maintainers; [ pSub ];
    };
  };

  github-webhook = buildPythonPackage rec {
    name = "github-webhook-${version}";
    version = "unstable-2016-03-11";

    # There is a PyPI package but an older one.
    src = pkgs.fetchgit {
      url = "https://github.com/bloomberg/python-github-webhook.git";
      rev = "ca1855479ee59c4373da5425dbdce08567605d49";
      sha256 = "0mqwig9281iyzbphp1d21a4pqdrf98vs9k8lqpqx6spzgqaczx5f";
    };

    propagatedBuildInputs = with self; [ flask ];
    # No tests
    doCheck = false;

    meta = {
      description = "A framework for writing webhooks for GitHub";
      license = licenses.mit;
      homepage = https://github.com/bloomberg/python-github-webhook;
    };
  };

  goobook = buildPythonPackage rec {
    name = "goobook-1.9";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url    = "mirror://pypi/g/goobook/${name}.tar.gz";
      sha256 = "02xmq8sjavza17av44ks510934wrshxnsm6lvhvazs45s92b671i";
    };

    buildInputs = with self; [ ];

    preConfigure = ''
      sed -i '/distribute/d' setup.py
    '';

    meta = {
      description = "Search your google contacts from the command-line or mutt";
      homepage    = https://pypi.python.org/pypi/goobook;
      license     = licenses.gpl3;
      maintainers = with maintainers; [ lovek323 hbunke ];
      platforms   = platforms.unix;
    };

    propagatedBuildInputs = with self; [ oauth2client gdata simplejson httplib2 keyring six rsa ];
  };

  googleapis_common_protos = callPackage ../development/python-modules/googleapis_common_protos { };

  google_api_core = callPackage ../development/python-modules/google_api_core { };

  google_api_python_client = buildPythonPackage rec {
    name = "google-api-python-client-${version}";
    version = "1.5.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/google-api-python-client/${name}.tar.gz";
      sha256 = "1ggxk094vqr4ia6yq7qcpa74b4x5cjd5mj74rq0xx9wp2jkrxmig";
    };

    # No tests included in archive
    doCheck = false;

    propagatedBuildInputs = with self; [ httplib2 six oauth2client uritemplate ];

    meta = {
      description = "The core Python library for accessing Google APIs";
      homepage = "https://code.google.com/p/google-api-python-client/";
      license = licenses.asl20;
      platforms = platforms.unix;
    };
  };

  google_apputils = buildPythonPackage rec {
    name = "google-apputils-0.4.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/google-apputils/${name}.tar.gz";
      sha256 = "1sxsm5q9vr44qzynj8l7p3l7ffb0zl1jdqhmmzmalkx941nbnj1b";
    };

    preConfigure = ''
      sed -i '/ez_setup/d' setup.py
    '';

    propagatedBuildInputs = with self; [ pytz gflags dateutil mox ];

    checkPhase = ''
      ${python.executable} setup.py google_test
    '';

    doCheck = true;

    meta = {
      description = "Google Application Utilities for Python";
      homepage = http://code.google.com/p/google-apputils-python;
    };
  };

  google_auth = callPackage ../development/python-modules/google_auth { };

  google_cloud_core = callPackage ../development/python-modules/google_cloud_core { };

  google_cloud_speech = callPackage ../development/python-modules/google_cloud_speech { };

  google_gax = callPackage ../development/python-modules/google_gax { };

  grammalecte = callPackage ../development/python-modules/grammalecte { };

  greenlet = buildPythonPackage rec {
    name = "greenlet-${version}";
    version = "0.4.10";
    disabled = isPyPy;  # builtin for pypy

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/greenlet/${name}.tar.gz";
      sha256 = "c4417624aa88380cdf0fe110a8a6e0dbcc26f80887197fe5df0427dfa348ae62";
    };

    propagatedBuildInputs = with self; [ six ];

    # see https://github.com/python-greenlet/greenlet/issues/85
    preCheck = ''
      rm tests/test_leaks.py
    '';

    meta = {
      homepage = https://pypi.python.org/pypi/greenlet;
      description = "Module for lightweight in-process concurrent programming";
      license     = licenses.lgpl2;
      platforms   = platforms.all;
    };
  };

  grib-api = disabledIf (!isPy27) (toPythonModule
    (pkgs.grib-api.override {
      enablePython = true;
      pythonPackages = self;
    }));

  grpcio = callPackage ../development/python-modules/grpcio { };

  gspread = buildPythonPackage rec {
    version = "0.2.3";
    name = "gspread-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/gspread/${name}.tar.gz";
      sha256 = "dba45ef9e652dcd8cf561ae65569bd6ecd18fcc77b991521490698fb2d847106";
    };

    meta = {
      description = "Google Spreadsheets client library";
      homepage = "https://github.com/burnash/gspread";
      license = licenses.mit;
    };
  };

  gyp = buildPythonPackage rec {
    name = "gyp-${version}";
    version = "2015-06-11";

    src = pkgs.fetchgit {
      url = "https://chromium.googlesource.com/external/gyp.git";
      rev = "fdc7b812f99e48c00e9a487bd56751bbeae07043";
      sha256 = "1imgxsl4mr1662vsj2mlnpvvrbz71yk00w8p85vi5bkgmc6awgiz";
    };

    prePatch = optionals pkgs.stdenv.isDarwin ''
      sed -i 's/raise.*No Xcode or CLT version detected.*/version = "7.0.0"/' pylib/gyp/xcode_emulation.py
    '';

    patches = optionals pkgs.stdenv.isDarwin [
      ../development/python-modules/gyp/no-darwin-cflags.patch
      ../development/python-modules/gyp/no-xcode.patch
    ];

    disabled = isPy3k;

    meta = {
      description = "A tool to generate native build files";
      homepage = https://chromium.googlesource.com/external/gyp/+/master/README.md;
      license = licenses.bsd3;
      maintainers = with maintainers; [ codyopel ];
      platforms = platforms.all;
    };
  };

  guessit = callPackage ../development/python-modules/guessit { };

  # used by flexget
  guessit_2_0 = callPackage ../development/python-modules/guessit/2.0.nix { };

  rebulk = callPackage ../development/python-modules/rebulk { };

  gunicorn = callPackage ../development/python-modules/gunicorn { };

  hawkauthlib = buildPythonPackage rec {
    name = "hawkauthlib-${version}";
    version = "0.1.1";
    src = pkgs.fetchgit {
      url = https://github.com/mozilla-services/hawkauthlib.git;
      rev = "refs/tags/v${version}";
      sha256 = "0mr1mpx4j9q7sch9arwfvpysnpf2p7ijy7072wilxm8pnj0bwvsi";
    };

    propagatedBuildInputs = with self; [ requests webob ];
  };

  hmmlearn = callPackage ../development/python-modules/hmmlearn { };

  hcs_utils = callPackage ../development/python-modules/hcs_utils { };

  hetzner = buildPythonPackage rec {
    name = "hetzner-${version}";
    version = "0.8.0";

    src = pkgs.fetchFromGitHub {
      repo = "hetzner";
      owner = "aszlig";
      rev = "v${version}";
      sha256 = "04q2q2w2qkhfly8rfjg2h5pnh42gs18l6cmipqc37yf7qvkw3nd0";
    };

    meta = {
      homepage = "https://github.com/RedMoonStudios/hetzner";
      description = "High-level Python API for accessing the Hetzner robot";
      license = licenses.bsd3;
      maintainers = with maintainers; [ aszlig ];
    };
  };


  htmllaundry = buildPythonPackage rec {
    name = "htmllaundry-2.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/htmllaundry/${name}.tar.gz";
      sha256 = "e428cba78d5a965e959f5dac2eb7d5f7d627dd889990d5efa8d4e03f3dd768d9";
    };

    buildInputs = with self; [ nose ];
    propagatedBuildInputs = with self; [ six lxml ];

    # some tests fail, probably because of changes in lxml
    # not relevant for me, if releavnt for you, fix it...
    doCheck = false;

    meta = {
      description = "Simple HTML cleanup utilities";
      license = licenses.bsd3;
    };
  };


  html5lib = callPackage ../development/python-modules/html5lib { };

  http_signature = buildPythonPackage (rec {
    name = "http_signature-0.1.4";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/http_signature/${name}.tar.gz";
      sha256 = "14acc192ef20459d5e11b4e800dd3a4542f6bd2ab191bf5717c696bf30936c62";
    };

    propagatedBuildInputs = with self; [pycrypto];

    meta = {
      homepage = https://github.com/atl/py-http-signature;
      description = "";
      license = licenses.mit;
    };
  });

  httpbin = callPackage ../development/python-modules/httpbin { };

  httplib2 = buildPythonPackage rec {
    name = "httplib2-0.9.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/httplib2/${name}.tar.gz";
      sha256 = "126rsryvw9vhbf3qmsfw9lf4l4xm2srmgs439lgma4cpag4s3ay3";
    };

    meta = {
      homepage = http://code.google.com/p/httplib2;
      description = "A comprehensive HTTP client library";
      license = licenses.mit;
      maintainers = with maintainers; [ garbas ];
    };
  };

  hvac = callPackage ../development/python-modules/hvac { };

  hypothesis = callPackage ../development/python-modules/hypothesis { };

  colored = buildPythonPackage rec {
    name = "colored-${version}";
    version = "1.1.5";
    src = pkgs.fetchurl {
      url = "mirror://pypi/c/colored/${name}.tar.gz";
      sha256 = "1r1vsypk8v7az82d66bidbxlndx1h7xd4m43hpg1a6hsjr30wrm3";
    };

    # No proper test suite
    doCheck = false;
  };


  xdis = buildPythonPackage rec {
    name = "xdis-${version}";
    version = "3.2.4";
    src = pkgs.fetchurl {
      url = "mirror://pypi/x/xdis/${name}.tar.gz";
      sha256 = "0g2lh70837vigcbc1i58349wp2xzrhlsg2ahc92sn8d3jwxja4dk";
    };
    propagatedBuildInputs = with self; [ nose six ];

    meta = {
      description = "Python cross-version byte-code disassembler and marshal routines";
      homepage = https://github.com/rocky/python-xdis/;
      license = licenses.mit;
    };
  };

  uncompyle6 = buildPythonPackage rec {
    name = "uncompyle6-${version}";
    version = "2.8.3";
    src = pkgs.fetchurl {
      url = "mirror://pypi/u/uncompyle6/${name}.tar.gz";
      sha256 = "0hx5sji6qjvnq1p0zhvyk5hgracpv2w6iar1j59qwllxv115ffi1";
    };
    propagatedBuildInputs = with self; [ spark_parser xdis ];
    meta = {
      description = "Python cross-version byte-code deparser";
      homepage = https://github.com/rocky/python-uncompyle6/;
      license = licenses.mit;
    };
  };

  lsi = buildPythonPackage rec {
    name = "lsi-${version}";
    version = "0.2.2";
    disabled = isPy3k;
    src = pkgs.fetchurl {
      url = "mirror://pypi/l/lsi/${name}.tar.gz";
      sha256 = "0429iilb06yhsmvj3xp6wyhfh1rp4ndxlhwrm80r97z0w7plrk94";
    };
    propagatedBuildInputs = [
      self.colored
      self.boto
      pkgs.openssh
      pkgs.which
    ];
    meta = {
      description = "CLI for querying and SSHing onto AWS EC2 instances";
      homepage = https://github.com/NarrativeScience/lsi;
      maintainers = [maintainers.adnelson];
      license = licenses.mit;
    };
  };

  hkdf = buildPythonPackage rec {
    name = "hkdf-${version}";
    version = "0.0.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hkdf/${name}.tar.gz";
      sha256 = "1jhxk5vhxmxxjp3zj526ry521v9inzzl8jqaaf0ma65w6k332ak2";
    };

    buildInputs = with self; [ nose ];

    checkPhase = ''
      nosetests
    '';

    meta = {
      description = "HMAC-based Extract-and-Expand Key Derivation Function (HKDF)";
      homepage = "https://github.com/casebeer/python-hkdf";
      license = licenses.bsd2;
    };
  };

  httpretty = buildPythonPackage rec {
    name = "httpretty-${version}";
    version = "0.8.10";
    doCheck = false;

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/httpretty/${name}.tar.gz";
      sha256 = "1nmdk6d89z14x3wg4yxywlxjdip16zc8bqnfb471z1365mr74jj7";
    };

    buildInputs = with self; [ tornado requests httplib2 sure nose coverage certifi ];

    propagatedBuildInputs = with self; [ urllib3 ];

    postPatch = ''
      sed -i -e 's/==.*$//' *requirements.txt
      # XXX: Drop this after version 0.8.4 is released.
      patch httpretty/core.py <<DIFF
      ***************
      *** 566 ****
      !                 'content-length': len(self.body)
      --- 566 ----
      !                 'content-length': str(len(self.body))
      DIFF

      # Explicit encoding flag is required with python3, unless locale is set.
      ${if !self.isPy3k then "" else
        "patch -p0 -i ${../development/python-modules/httpretty/setup.py.patch}"}
    '';

    meta = {
      homepage = "http://falcao.it/HTTPretty/";
      description = "HTTP client request mocking tool";
      license = licenses.mit;
    };
  };

  icalendar = buildPythonPackage rec {
    version = "3.9.0";
    name = "icalendar-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/icalendar/${name}.tar.gz";
      sha256 = "93d0b94eab23d08f62962542309916a9681f16de3d5eca1c75497f30f1b07792";
    };

    buildInputs = with self; [ setuptools ];
    propagatedBuildInputs = with self; [ dateutil pytz ];

    meta = {
      description = "A parser/generator of iCalendar files";
      homepage = "http://icalendar.readthedocs.org/";
      license = licenses.bsd2;
      maintainers = with maintainers; [ olcai ];
    };
  };

  imageio = buildPythonPackage rec {
    name = "imageio-${version}";
    version = "1.6";

    src = pkgs.fetchurl {
      url = "https://github.com/imageio/imageio/archive/v${version}.tar.gz";
      sha256 = "195snkk3fsbjqd5g1cfsd9alzs5q45gdbi2ka9ph4yxqb31ijrbv";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ numpy ];

    checkPhase = ''
      py.test
    '';

    # Tries to write in /var/tmp/.imageio
    doCheck = false;

    meta = {
      description = "Library for reading and writing a wide range of image, video, scientific, and volumetric data formats";
      homepage = http://imageio.github.io/;
      license = licenses.bsd2;
    };
  };

  importlib = buildPythonPackage rec {
    name = "importlib-1.0.2";

    disabled = (!isPy26) || isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/importlib/importlib-1.0.2.tar.gz";
      sha256 = "131jvp6ahllcqblszjg6fxrzh4k50w8g60sq924b4nb8lxm9dl14";
    };
  };

  inflection = callPackage ../development/python-modules/inflection { };

  influxdb = buildPythonPackage rec {
    name = "influxdb-4.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/influxdb/${name}.tar.gz";
      sha256 = "0injsml6zmb3hkgc03117fdlg573kbfgjbijpd5npf0vsy0xnpvz";
    };

    # ImportError: No module named tests
    doCheck = false;
    propagatedBuildInputs = with self; [ requests dateutil pytz six ];

    meta = {
      description = "Python client for InfluxDB";
      homepage = https://github.com/influxdb/influxdb-python;
      license = licenses.mit;
    };
  };

  infoqscraper = buildPythonPackage rec {
    name = pname + "-" + version;
    version = "0.1.0";
    pname = "infoqscraper";

    src = pkgs.fetchFromGitHub {
      owner = "cykl";
      repo = pname;
      rev = "v" + version;
      sha256 = "07mxp4mla7fwfc032f3mxrhjarnhkjqdxxibf9ba87c93z3dq8jj";
    };

    # requires network
    doCheck = false;

    buildInputs = with self; [ html5lib ];
    propagatedBuildInputs = (with self; [ six beautifulsoup4 ])
                         ++ (with pkgs; [ ffmpeg swftools rtmpdump ]);

    meta = {
      description = "Discover presentations and/or create a movie consisting of slides and audio track from an infoq url";
      homepage = "https://github.com/cykl/infoqscraper/wiki";
      license = licenses.mit;
      maintainers = with maintainers; [ edwtjo ];
    };
  };

  inifile = buildPythonPackage rec {
    name = "inifile-0.3";

    meta = {
      description = "A small INI library for Python";
      homepage    = "https://github.com/mitsuhiko/python-inifile";
      license     = "BSD";
      maintainers = with maintainers; [ vozz ];
    };

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/inifile/${name}.tar.gz";
      sha256 = "0zgd53czc1irwx6b5zip8xlmyfr40hz2pd498d8yv61znj6lm16h";
    };
  };

  interruptingcow = callPackage ../development/python-modules/interruptingcow {};

  iptools = buildPythonPackage rec {
    version = "0.6.1";
    name = "iptools-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/iptools/iptools-${version}.tar.gz";
      sha256 = "0f03875a5bed740ba4bf44decb6a78679cca914a1ee8a6cc468114485c4d98e3";
    };

    buildInputs = with self; [ nose ];

    meta = {
      description = "Utilities for manipulating IP addresses including a class that can be used to include CIDR network blocks in Django's INTERNAL_IPS setting";
      homepage = https://pypi.python.org/pypi/iptools;
    };
  };

  ipy = callPackage ../development/python-modules/IPy { };

  ipykernel = callPackage ../development/python-modules/ipykernel { };

  ipyparallel = callPackage ../development/python-modules/ipyparallel { };

  # Newer versions of IPython no longer support Python 2.7.
  ipython = if isPy27 then self.ipython_5 else self.ipython_6;

  ipython_5 = callPackage ../development/python-modules/ipython/5.nix { };

  ipython_6 = callPackage ../development/python-modules/ipython { };

  ipython_genutils = callPackage ../development/python-modules/ipython_genutils { };

  ipywidgets = callPackage ../development/python-modules/ipywidgets { };

  ipaddr = buildPythonPackage rec {
    name = "ipaddr-${version}";
    version = "2.1.11";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/ipaddr/${name}.tar.gz";
      sha256 = "1dwq3ngsapjc93fw61rp17fvzggmab5x1drjzvd4y4q0i255nm8v";
    };

    meta = {
      description = "Google's IP address manipulation library";
      homepage = http://code.google.com/p/ipaddr-py/;
      license = licenses.asl20;
    };
  };

  ipaddress = if (pythonAtLeast "3.3") then null else buildPythonPackage rec {
    name = "ipaddress-1.0.18";

    src = pkgs.fetchurl {
      url = "mirror://pypi/i/ipaddress/${name}.tar.gz";
      sha256 = "1q8klj9d84cmxgz66073x1j35cplr3r77vx1znhxiwl5w74391ax";
    };

    checkPhase = ''
      ${python.interpreter} test_ipaddress.py
    '';

    meta = {
      description = "Port of the 3.3+ ipaddress module to 2.6, 2.7, and 3.2";
      homepage = https://github.com/phihag/ipaddress;
      license = licenses.psfl;
    };
  };

  ipdb = buildPythonPackage rec {
    name = "ipdb-${version}";
    version = "0.8.1";

    disabled = isPyPy;  # setupterm: could not find terminfo database
    src = pkgs.fetchurl {
      url = "mirror://pypi/i/ipdb/${name}.zip";
      sha256 = "1763d1564113f5eb89df77879a8d3213273c4d7ff93dcb37a3070cdf0c34fd7c";
    };
    propagatedBuildInputs = with self; [ ipython ];
  };

  ipdbplugin = buildPythonPackage {
    name = "ipdbplugin-1.4";
    src = pkgs.fetchurl {
      url = "mirror://pypi/i/ipdbplugin/ipdbplugin-1.4.tar.gz";
      sha256 = "4778d78b5d0af1a2a6d341aed9e72eb73b1df6b179e145b4845d3a209137029c";
    };
    propagatedBuildInputs = with self; [ self.nose self.ipython ];
  };

  pythonIRClib = buildPythonPackage rec {
    name = "irclib-${version}";
    version = "0.4.8";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/python-irclib/python-irclib-${version}.tar.gz";
      sha256 = "1x5456y4rbxmnw4yblhb4as5791glcw394bm36px3x6l05j3mvl1";
    };

    patches = [(pkgs.fetchurl {
      url = "http://trac.uwc.ac.za/trac/python_tools/browser/xmpp/resources/irc-transport/irclib.py.diff?rev=387&format=raw";
      name = "irclib.py.diff";
      sha256 = "5fb8d95d6c95c93eaa400b38447c63e7a176b9502bc49b2f9b788c9905f4ec5e";
    })];

    patchFlags = "irclib.py";

    propagatedBuildInputs = with self; [ paver ];

    disabled = isPy3k;
    meta = {
      description = "Python IRC library";
      homepage = https://bitbucket.org/jaraco/irc;
      license = with licenses; [ lgpl21 ];
    };
  };

  iso-639 = callPackage ../development/python-modules/iso-639 {};

  iso3166 = callPackage ../development/python-modules/iso3166 {};

  iso8601 = callPackage ../development/python-modules/iso8601 { };

  isort = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "isort";
    version = "4.2.5";
    src = pkgs.fetchurl {
      url = "mirror://pypi/i/${pname}/${name}.tar.gz";
      sha256 = "0p7a6xaq7zxxq5vr5gizshnsbk2afm70apg97xwfdxiwyi201cjn";
    };
    buildInputs = with self; [ mock pytest ];
    # No tests distributed
    doCheck = false;
    meta = {
      description = "A Python utility / library to sort Python imports";
      homepage = https://github.com/timothycrosley/isort;
      license = licenses.mit;
      maintainers = with maintainers; [ couchemar nand0p ];
    };
  };

  jabberbot = callPackage ../development/python-modules/jabberbot {};

  jedi = callPackage ../development/python-modules/jedi { };

  jellyfish = callPackage ../development/python-modules/jellyfish { };

  j2cli = buildPythonPackage rec {
    name = "j2cli-${version}";
    version = "0.3.1-0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/j2cli/${name}.tar.gz";
      sha256 = "0y3w1x9935qzx8w6m2r6g4ghyjmxn33wryiif6xb56q7cj9w1433";
    };

    disabled = ! (isPy26 || isPy27);

    buildInputs = [ self.nose ];

    propagatedBuildInputs = with self; [ jinja2 pyyaml ];

    meta = {
      homepage = https://github.com/kolypto/j2cli;
      description = "Jinja2 Command-Line Tool";
      license = licenses.bsd3;
      longDescription = ''
        J2Cli is a command-line tool for templating in shell-scripts,
        leveraging the Jinja2 library.
      '';
      platforms = platforms.all;
      maintainers = with maintainers; [ rushmorem ];
    };
  };

  jinja2 = callPackage ../development/python-modules/jinja2 { };

  jinja2_time = buildPythonPackage rec {
    version = "0.2.0";
    name = "jinja2-time-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jinja2-time/${name}.tar.gz";
      sha256 = "0h0dr7cfpjnjj8bgl2vk9063a53649pn37wnlkd8hxjy656slkni";
    };

    propagatedBuildInputs = with self; [ arrow jinja2 ];

    meta = {
      homepage = https://github.com/hackebrot/jinja2-time;
      description = "Jinja2 Extension for Dates and Times";
      license = licenses.mit;
    };
  };

  jinja2_pluralize = callPackage ../development/python-modules/jinja2_pluralize { };

  jmespath = buildPythonPackage rec {
    name = "jmespath-0.9.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jmespath/${name}.tar.gz";
      sha256 = "0g9xvl69y7nr3w7ag4fsp6sm4fqf6vrqjw7504x2hzrrsh3ampq8";
    };

    buildInputs = with self; [ nose ];
    propagatedBuildInputs = with self; [ ply ];

    meta = {
      homepage = https://github.com/boto/jmespath;
      description = "JMESPath allows you to declaratively specify how to extract elements from a JSON document";
      license = "BSD";
    };
  };

  journalwatch = callPackage ../tools/system/journalwatch {
    inherit (self) systemd pytest;
  };

  jsondate = callPackage ../development/python-modules/jsondate { };

  jsondiff = callPackage ../development/python-modules/jsondiff { };

  jsonnet = buildPythonPackage {
    inherit (pkgs.jsonnet) name src;
  };

  jupyter_client = callPackage ../development/python-modules/jupyter_client { };

  jupyter_core = callPackage ../development/python-modules/jupyter_core { };

  jupyterhub = callPackage ../development/python-modules/jupyterhub { };

  jupyterhub-ldapauthenticator = callPackage ../development/python-modules/jupyterhub-ldapauthenticator { };

  jsonpath_rw = buildPythonPackage rec {
    name = "jsonpath-rw-${version}";
    version = "1.4.0";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/j/jsonpath-rw/${name}.tar.gz";
      sha256 = "05c471281c45ae113f6103d1268ec7a4831a2e96aa80de45edc89b11fac4fbec";
    };

    propagatedBuildInputs = with self; [
      ply
      six
      decorator
    ];

    # ImportError: No module named tests
    doCheck = false;

    meta = {
      homepage = https://github.com/kennknowles/python-jsonpath-rw;
      description = "A robust and significantly extended implementation of JSONPath for Python, with a clear AST for metaprogramming";
      license = licenses.asl20;
    };
  };

  kerberos = buildPythonPackage rec {
    name = "kerberos-1.2.4";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/source/k/kerberos/${name}.tar.gz";
      sha256 = "11q9jhzdl88jh8jgn7cycq034m36g2ncxds7mr3vqkngpcirkx6n";
    };

    buildInputs = [ pkgs.kerberos ];

    meta = {
      description = "Kerberos high-level interface";
      homepage = https://pypi.python.org/pypi/kerberos;
      license = licenses.asl20;
    };
  };

  keyring = callPackage ../development/python-modules/keyring { };

  keyutils = callPackage ../development/python-modules/keyutils { };

  klein = buildPythonPackage rec {
    name = "klein-15.3.1";
    src = pkgs.fetchurl {
      url = "mirror://pypi/k/klein/${name}.tar.gz";
      sha256 = "1hl2psnn1chm698rimyn9dgcpl1mxgc8dj11b3ipp8z37yfjs3z9";
    };

    disabled = isPy3k;

    propagatedBuildInputs = with self; [ werkzeug twisted ];

    meta = {
      description = "Klein Web Micro-Framework";
      homepage    = "https://github.com/twisted/klein";
      license     = licenses.mit;
    };
  };

  koji = callPackage ../development/python-modules/koji { };

  kombu = buildPythonPackage rec {
    name = "kombu-${version}";
    version = "4.0.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/k/kombu/${name}.tar.gz";
      sha256 = "18hiricdnbnlz6hx3hbaa4dni6npv8rbid4dhf7k02k16qm6zz6h";
    };

    # Backport fix for python-3.6 from master (see issue https://github.com/celery/kombu/issues/675)
    # TODO remove at next update
    patches = [ (pkgs.fetchpatch {
      url = "https://github.com/celery/kombu/commit/dc3fceff59d79ceac3f8f11a5d697beabb4b7a7f.patch";
      sha256 = "0s6gsihzjvmpffc7xrrcijw00r56yb74jg0sbjgng2v1324z1da9";
      name = "don-t-modify-dict-size-while-iterating-over-it";
    }) ];

    buildInputs = with self; [ pytest case pytz ];

    propagatedBuildInputs = with self; [ amqp ];

    meta = {
      description = "Messaging library for Python";
      homepage    = "http://github.com/celery/kombu";
      license     = licenses.bsd3;
    };
  };

  konfig = callPackage ../development/python-modules/konfig { };

  kitchen = callPackage ../development/python-modules/kitchen/default.nix { };

  kubernetes = callPackage ../development/python-modules/kubernetes/default.nix { };

  pylast = callPackage ../development/python-modules/pylast/default.nix { };

  pylru = callPackage ../development/python-modules/pylru/default.nix { };

  lark-parser = callPackage ../development/python-modules/lark-parser { };

  lazy-object-proxy = buildPythonPackage rec {
    name = "lazy-object-proxy-${version}";
    version = "1.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/lazy-object-proxy/${name}.tar.gz";
      sha256 = "22ed751a2c63c6cf718674fd7461b1dfc45215bab4751ca32b6c9b8cb2734cb3";
    };

    buildInputs = with self; [ pytest ];
    checkPhase = ''
      py.test tests
    '';

    # Broken tests. Seem to be fixed upstream according to Travis.
    doCheck = false;

    meta = {
      description = "A fast and thorough lazy object proxy";
      homepage = https://github.com/ionelmc/python-lazy-object-proxy;
      license = with licenses; [ bsd2 ];
    };

  };

  ldaptor = callPackage ../development/python-modules/ldaptor { };

  le = buildPythonPackage rec {
    name = "le-${version}";
    version = "1.4.29";

    src = pkgs.fetchurl {
      url = "https://github.com/logentries/le/archive/v${version}.tar.gz";
      sha256 = "d29738937cb6e714b6ec2ae74b66b1983482ffd54b4faa40767af18509521d4c";
    };

    disabled = isPy3k;

    doCheck = false;

    propagatedBuildInputs = with self; [ simplejson psutil ];

    meta = {
      homepage = "https://github.com/logentries/le";
      description = "Logentries agent";
    };
  };

  lektor = buildPythonPackage rec {
    name = "lektor-${version}";

    version = "2.3";

    src = pkgs.fetchgit {
      url = "https://github.com/lektor/lektor";
      rev = "refs/tags/${version}";
      sha256 = "1n0ylh1sbpvi9li3g6a7j7m28njfibn10y6s2gayjxwm6fpphqxy";
    };

    LC_ALL="en_US.UTF-8";

    meta = {
      description = "A static content management system";
      homepage    = "https://www.getlektor.com/";
      license     = "BSD";
      maintainers = with maintainers; [ vozz ];
    };

    # No tests included in archive
    doCheck = false;

    propagatedBuildInputs = with self; [
      click watchdog exifread requests mistune inifile Babel jinja2
      flask pyopenssl ndg-httpsclient pkgs.glibcLocales
    ];
  };

  python-oauth2 = callPackage ../development/python-modules/python-oauth2 { };

  python-Levenshtein = buildPythonPackage rec {
    name = "python-Levenshtein-${version}";
    version = "0.12.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-Levenshtein/${name}.tar.gz";
      sha256 = "1c9ybqcja31nghfcc8xxbbz9h60s9qi12b9hr4jyl69xbvg12fh3";
    };

    # No tests included in archive
    doCheck = false;

    meta = {
      description = "Functions for fast computation of Levenshtein distance and string similarity";
      homepage    = "https://github.com/ztane/python-Levenshtein";
      license     = licenses.gpl2;
      maintainers = with maintainers; [ aske ];
    };
  };

  libcloud = buildPythonPackage (rec {
    name = "libcloud-1.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/a/apache-libcloud/apache-${name}.tar.bz2";
      sha256 = "0qlhyz5f32xg8i10biyzqscks8d28vklk63hvj45vzy1amw60kqz";
    };

    buildInputs = with self; [ mock ];

    propagatedBuildInputs = with self; [ pycrypto ];
    preConfigure = "cp libcloud/test/secrets.py-dist libcloud/test/secrets.py";

    # failing tests for 26 and 27
    doCheck = false;

    meta = {
      description = "A unified interface to many cloud providers";
      homepage = http://incubator.apache.org/libcloud/;
    };
  });

  libgpuarray = callPackage ../development/python-modules/libgpuarray {
    clblas = pkgs.clblas.override { boost = self.boost; };
    cudaSupport = pkgs.config.cudaSupport or false;
  };

  librepo = toPythonModule (pkgs.librepo.override {
    inherit python;
  });

  libnacl = callPackage ../development/python-modules/libnacl {
    inherit (pkgs) libsodium;
  };

  libplist = disabledIf isPy3k
    (toPythonModule (pkgs.libplist.override{python2Packages=self; })).py;

  libxml2 = disabledIf isPy3k
    (toPythonModule (pkgs.libxml2.override{pythonSupport=true; python2=python;})).py;

  libxslt = disabledIf isPy3k
    (toPythonModule (pkgs.libxslt.override{pythonSupport=true; python2=python; inherit (self) libxml2;})).py;

  limits = callPackage ../development/python-modules/limits { };

  limnoria = buildPythonPackage rec {
    name = "limnoria-${version}";
    version = "2016.05.06";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/limnoria/${name}.tar.gz";
      sha256 = "09kbii5559d09jjb6cryj8rva1050r54dvb67hlcvxhy8g3gr1y3";
    };

    patchPhase = ''
      sed -i 's/version=version/version="${version}"/' setup.py
    '';
    buildInputs = with self; [ pkgs.git ];
    propagatedBuildInputs = with self; [  ];

    doCheck = false;

    meta = {
      description = "A modified version of Supybot, an IRC bot";
      homepage = http://supybot.fr.cr;
      license = licenses.bsd3;
      maintainers = with maintainers; [ goibhniu ];
    };
  };

  line_profiler = callPackage ../development/python-modules/line_profiler { };

  linode = buildPythonPackage rec {
    name = "linode-${version}";
    version = "0.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/linode/linode-${version}.tar.gz";
      sha256 = "db3c2a7fab8966d903a63f16c515bff241533e4ef2d746aa7aae4a49bba5e573";
    };

    propagatedBuildInputs = with self; [ requests ];

    meta = {
      homepage = "https://github.com/ghickman/linode";
      description = "A thin python wrapper around Linode's API";
      license = licenses.mit;
      maintainers = with maintainers; [ nslqqq ];
    };
  };

  linode-api = callPackage ../development/python-modules/linode-api { };

  livereload = callPackage ../development/python-modules/livereload { };

  llfuse = callPackage ../development/python-modules/llfuse {
    fuse = pkgs.fuse;  # use "real" fuse, not the python module
  };

  locustio = callPackage ../development/python-modules/locustio { };

  llvmlite = callPackage ../development/python-modules/llvmlite { llvm = pkgs.llvm; };

  lockfile = buildPythonPackage rec {
    pname = "lockfile";
    version = "0.12.2";
    name = "${pname}-${version}";
    src = pkgs.fetchurl {
      url = "mirror://pypi/${builtins.substring 0 1 pname}/${pname}/${name}.tar.gz";
      sha256 = "6aed02de03cba24efabcd600b30540140634fc06cfa603822d508d5361e9f799";
    };

    buildInputs = with self; [
      pbr nose
    ];

    checkPhase = ''
      nosetests
    '';

    meta = {
      homepage = http://launchpad.net/pylockfile;
      description = "Platform-independent advisory file locking capability for Python applications";
      license = licenses.asl20;
    };
  };

  logilab_common = callPackage ../development/python-modules/logilab/common.nix {};

  logilab-constraint = callPackage ../development/python-modules/logilab/constraint.nix {};

  lxml = callPackage ../development/python-modules/lxml {inherit (pkgs) libxml2 libxslt;};

  lxc = buildPythonPackage (rec {
    name = "python-lxc-unstable-2016-08-25";
    disabled = !isPy27;

    src = pkgs.fetchFromGitHub {
      owner = "lxc";
      repo = "python2-lxc";
      rev = "0553f05d23b56b59bf3015fa5e45bfbfab9021ef";
      sha256 = "0p9kb20xvq91gx2wfs3vppb7vsp8kmd90i3q95l4nl1y4aismdn4";
    };

    buildInputs = [ pkgs.lxc ];

    meta = {
      description = "Out of tree python 2.7 binding for liblxc";
      homepage = https://github.com/lxc/python2-lxc;
      license = licenses.lgpl2;
      maintainers = with maintainers; [ mic92 ];
    };
  });

  py_scrypt = callPackage ../development/python-modules/py_scrypt/default.nix { };

  python_magic = callPackage ../development/python-modules/python-magic { };

  magic = buildPythonPackage rec {
    name = "${pkgs.file.name}";

    src = pkgs.file.src;

    patchPhase = ''
      substituteInPlace python/magic.py --replace "find_library('magic')" "'${pkgs.file}/lib/libmagic${stdenv.hostPlatform.extensions.sharedLibrary}'"
    '';

    buildInputs = with self; [ pkgs.file ];

    preConfigure = "cd python";

    # No test suite
    doCheck = false;

    meta = {
      description = "A Python wrapper around libmagic";
      homepage = http://www.darwinsys.com/file/;
    };
  };

  m2crypto = buildPythonPackage rec {
    version = "0.24.0";
    name = "m2crypto-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/M/M2Crypto/M2Crypto-${version}.tar.gz";
      sha256 = "1s2y0pf2zg7xf4nfwrw7zhwbk615r5a7bgi5wwkwzh6jl50n99c0";
    };

    buildInputs = with self; [ pkgs.swig2 pkgs.openssl ];

    preConfigure = ''
      substituteInPlace setup.py --replace "self.openssl = '/usr'" "self.openssl = '${pkgs.openssl.dev}'"
    '';

    doCheck = false; # another test that depends on the network.

    meta = {
      description = "A Python crypto and SSL toolkit";
      homepage = http://chandlerproject.org/Projects/MeTooCrypto;
    };
  };

  Mako = callPackage ../development/python-modules/Mako { };

  manifestparser = callPackage ../development/python-modules/marionette-harness/manifestparser.nix {};
  marionette_driver = callPackage ../development/python-modules/marionette-harness/marionette_driver.nix {};
  mozcrash = callPackage ../development/python-modules/marionette-harness/mozcrash.nix {};
  mozdevice = callPackage ../development/python-modules/marionette-harness/mozdevice.nix {};
  mozfile = callPackage ../development/python-modules/marionette-harness/mozfile.nix {};
  mozhttpd = callPackage ../development/python-modules/marionette-harness/mozhttpd.nix {};
  mozinfo = callPackage ../development/python-modules/marionette-harness/mozinfo.nix {};
  mozlog = callPackage ../development/python-modules/marionette-harness/mozlog.nix {};
  moznetwork = callPackage ../development/python-modules/marionette-harness/moznetwork.nix {};
  mozprocess = callPackage ../development/python-modules/marionette-harness/mozprocess.nix {};
  mozprofile = callPackage ../development/python-modules/marionette-harness/mozprofile.nix {};
  mozrunner = callPackage ../development/python-modules/marionette-harness/mozrunner.nix {};
  moztest = callPackage ../development/python-modules/marionette-harness/moztest.nix {};
  mozversion = callPackage ../development/python-modules/marionette-harness/mozversion.nix {};
  marionette-harness = callPackage ../development/python-modules/marionette-harness {};

  marisa = callPackage ../development/python-modules/marisa {
    marisa = pkgs.marisa;
  };

  markupsafe = buildPythonPackage rec {
    name = "markupsafe-${version}";
    version = "1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/M/MarkupSafe/MarkupSafe-${version}.tar.gz";
      sha256 = "0rdn1s8x9ni7ss8rfiacj7x1085lx8mh2zdwqslnw8xc3l4nkgm6";
    };

    meta = {
      description = "Implements a XML/HTML/XHTML Markup safe string";
      homepage = http://dev.pocoo.org;
      license = licenses.bsd3;
      maintainers = with maintainers; [ domenkozar garbas ];
    };
  };

  marshmallow = callPackage ../development/python-modules/marshmallow { };

  marshmallow-sqlalchemy = callPackage ../development/python-modules/marshmallow-sqlalchemy { };

  manuel = buildPythonPackage rec {
    name = "manuel-${version}";
    version = "1.8.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/manuel/${name}.tar.gz";
      sha256 = "1diyj6a8bvz2cdf9m0g2bbx9z2yjjnn3ylbg1zinpcjj6vldfx59";
    };

    propagatedBuildInputs = with self; [ six zope_testing ];

    meta = {
      description = "A documentation builder";
      homepage = https://pypi.python.org/pypi/manuel;
      license = licenses.zpl20;
    };
  };

  mapsplotlib = buildPythonPackage rec {
    name = "mapsplotlib-${version}";
    version = "1.0.6";

    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mapsplotlib/${name}.tar.gz";
      sha256 = "09gpws3x0jd88n636baxx5izjffrpjy4j6jl8l7vj29yzvrdr2bp";
    };

    propagatedBuildInputs = with self; [ matplotlib scipy pandas requests pillow ];

    meta = {
      description = "Custom Python plots on a Google Maps background";
      homepage = https://github.com/tcassou/mapsplotlib;
      maintainers = [ maintainers.rob ];
    };
  };

  markdown = callPackage ../development/python-modules/markdown { };

  markdownsuperscript = callPackage ../development/python-modules/markdownsuperscript {};

  markdown-macros = buildPythonPackage rec {
    name = "markdown-macros-${version}";
    version = "0.1.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/markdown-macros/${name}.tar.gz";
      sha256 = "1lzvrb7nci22yp21ab2qqc9p0fhkazqj29vw0wln2r4ckb2nbawv";
    };

    patches = [
      # Fixes a bug with markdown>2.4
      (pkgs.fetchpatch {
        url = "https://github.com/wnielson/markdown-macros/pull/1.patch";
        sha256 = "17njbgq2srzkf03ar6yn92frnsbda3g45cdi529fdh0x8mmyxci0";
      })
    ];

    prePatch = ''
      substituteInPlace setup.py --replace "distribute" "setuptools"
    '';

    propagatedBuildInputs = with self; [ markdown ];

    doCheck = false;

    meta = {
      description = "An extension for python-markdown that makes writing trac-like macros easy";
      homepage = https://github.com/wnielson/markdown-macros;
      license = licenses.mit;
      maintainers = [ maintainers.abigailbuccaneer ];
    };
  };

  mathics = if (versionOlder self.django.version "1.8") ||
               (versionAtLeast self.django.version "1.9")
            then throw "mathics only supports django-1.8.x"
            else buildPythonPackage rec {
    name = "mathics-${version}";
    version = "0.9";
    src = pkgs.fetchFromGitHub {
      owner = "mathics";
      repo = "Mathics";
      rev = "v${version}";
      sha256 = "0xzz7j8xskj5y6as178mjmm0i2xbhd4q4mwmdnvghpd2aqq3qx1c";
    };

    disabled = isPy26;

    buildInputs = with self; [ pexpect ];

    prePatch = ''
      substituteInPlace setup.py --replace "sympy==0.7.6" "sympy"
    '';

    postFixup = ''
      wrapPythonProgramsIn $out/bin $out
      patchPythonScript $out/${python.sitePackages}/mathics/manage.py
    '';

    propagatedBuildInputs = with self; [
      cython
      sympy
      django
      ply
      mpmath
      dateutil
      colorama
      six
    ];

    meta = {
      description = "A general-purpose computer algebra system";
      homepage = http://www.mathics.org;
      license = licenses.gpl3;
      maintainers = [ maintainers.benley ];
    };
  };


  matplotlib = callPackage ../development/python-modules/matplotlib/default.nix {
    stdenv = if stdenv.isDarwin then pkgs.clangStdenv else pkgs.stdenv;
    enableGhostscript = true;
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
  };

  matrix-client = callPackage ../development/python-modules/matrix-client/default.nix { };

  maya = callPackage ../development/python-modules/maya { };

  mccabe = callPackage ../development/python-modules/mccabe { };

  mechanize = buildPythonPackage (rec {
    name = "mechanize-0.3.5";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mechanize/${name}.tar.gz";
      sha256 = "0rki9nl4y42q694parafcsdcdqvkdjckrbg6n0691302lfsrkyfl";
    };

    propagatedBuildInputs = with self; [ html5lib ];

    doCheck = false;

    meta = {
      description = "Stateful programmatic web browsing in Python";

      homepage = http://wwwsearch.sourceforge.net/;

      license = "BSD-style";
    };
  });

  MechanicalSoup = callPackage ../development/python-modules/MechanicalSoup/default.nix { };

  meld3 = buildPythonPackage rec {
    name = "meld3-1.0.0";

    src = pkgs.fetchurl {
      url = mirror://pypi/m/meld3/meld3-1.0.0.tar.gz;
      sha256 = "57b41eebbb5a82d4a928608962616442e239ec6d611fe6f46343e765e36f0b2b";
    };

    doCheck = false;

    meta = {
      description = "An HTML/XML templating engine used by supervisor";
      homepage = https://github.com/supervisor/meld3;
      license = licenses.free;
    };
  };

  meliae = callPackage ../development/python-modules/meliae {};

  meinheld = callPackage ../development/python-modules/meinheld { };

  memcached = buildPythonPackage rec {
    name = "memcached-1.51";

    src = if isPy3k then pkgs.fetchurl {
      url = "mirror://pypi/p/python3-memcached/python3-${name}.tar.gz";
      sha256 = "0na8b369q8fivh3y0nvzbvhh3lgvxiyyv9xp93cnkvwfsr8mkgkw";
    } else pkgs.fetchurl {
      url = "http://ftp.tummy.com/pub/python-memcached/old-releases/python-${name}.tar.gz";
      sha256 = "124s98m6hvxj6x90d7aynsjfz878zli771q96ns767r2mbqn7192";
    };

    meta = {
      description = "Python API for communicating with the memcached distributed memory object cache daemon";
      homepage = http://www.tummy.com/Community/software/python-memcached/;
    };
  };


  memory_profiler = buildPythonPackage rec {
    name = "memory_profiler-${version}";
    version = "0.41";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/memory_profiler/${name}.tar.gz";
      sha256 = "dce6e931c281662a500b142595517d095267216472c2926e5ec8edab89898d10";
    };

    # Tests don't import profile
    doCheck = false;

    meta = {
      description = "A module for monitoring memory usage of a python program";
      homepage = https://pypi.python.org/pypi/memory_profiler;
      license = licenses.bsd3;
    };
  };

  metaphone = callPackage ../development/python-modules/metaphone { };

  mezzanine = buildPythonPackage rec {
    version = "3.1.10";
    name = "mezzanine-${version}";

    src = pkgs.fetchurl {
      url = "https://github.com/stephenmcd/mezzanine/archive/${version}.tar.gz";
      sha256 = "1cd7d3dji8q4mvcnf9asxn8j109pd5g5d5shr6xvn0iwr35qprgi";
    };
    patches = [ ../development/python-modules/mezzanine/writable_settings.patch ];

    disabled = isPyPy;

    buildInputs = with self; [ pyflakes pep8 ];
    propagatedBuildInputs = with self; [
      django filebrowser_safe grappelli_safe bleach tzlocal beautifulsoup4
      requests requests_oauthlib future pillow
    ];

    # Tests Fail Due to Syntax Warning, Fixed for v3.1.11+
    doCheck = false;
    # sed calls will be unecessary in v3.1.11+
    preConfigure = ''
      sed -i 's/==/>=/' setup.py
    '';

    LC_ALL="en_US.UTF-8";

    meta = {
      description = ''
        A content management platform built using the Django framework
      '';
      longDescription = ''
        Mezzanine is a powerful, consistent, and flexible content management
        platform. Built using the Django framework, Mezzanine provides a
        simple yet highly extensible architecture that encourages diving in and
        hacking on the code. Mezzanine is BSD licensed and supported by a
        diverse and active community.

        In some ways, Mezzanine resembles tools such as Wordpress that provide
        an intuitive interface for managing pages, blog posts, form data, store
        products, and other types of content. But Mezzanine is also different.
        Unlike many other platforms that make extensive use of modules or
        reusable applications, Mezzanine provides most of its functionality by
        default. This approach yields a more integrated and efficient platform.
      '';
      homepage = http://mezzanine.jupo.org/;
      downloadPage = https://github.com/stephenmcd/mezzanine/releases;
      license = licenses.free;
      maintainers = with maintainers; [ prikhi ];
      platforms = platforms.linux;
      broken = true; # broken dependency of django within filebrowser_safe
    };
  };

  micawber = callPackage ../development/python-modules/micawber { };

  minimock = buildPythonPackage rec {
    version = "1.2.8";
    name = "minimock-${version}";

    src = pkgs.fetchurl {
      url = "https://bitbucket.org/jab/minimock/get/${version}.zip";
      sha256 = "c88fa8a7120623f23990a7f086a9657f6ced09025a55e3be8649a30b4945441a";
    };

    buildInputs = with self; [ nose ];

    checkPhase = "./test";

    meta = {
      description = "A minimalistic mocking library for python";
      homepage = https://pypi.python.org/pypi/MiniMock;
    };
  };

  moviepy = buildPythonPackage rec {
    name = "moviepy-${version}";
    version = "0.2.2.11";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/moviepy/${name}.tar.gz";
      sha256 = "d937d817e534efc54eaee2fc4c0e70b48fcd81e1528cd6425f22178704681dc3";
    };

    # No tests
    doCheck = false;
    propagatedBuildInputs = with self; [ numpy decorator imageio tqdm ];

    meta = {
      description = "Video editing with Python";
      homepage = http://zulko.github.io/moviepy/;
      license = licenses.mit;
    };
  };

  mozterm = callPackage ../development/python-modules/mozterm { };

  mplleaflet = callPackage ../development/python-modules/mplleaflet { };

  multidict = callPackage ../development/python-modules/multidict { };

  munch = buildPythonPackage rec {
    name = "munch-${version}";
    version = "2.0.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/munch/${name}.tar.gz";
      sha256 = "1420683a94f3a2ffc77935ddd28aa9ccb540dd02b75e02ed7ea863db437ab8b2";
    };

    meta = {
      description = "A dot-accessible dictionary (a la JavaScript objects)";
      license = licenses.mit;
      homepage = https://github.com/Infinidat/munch;
    };
  };

  nototools = callPackage ../data/fonts/noto-fonts/tools.nix { };

  rainbowstream = buildPythonPackage rec {
    name = "rainbowstream-${version}";
    version = "1.3.7";

    src = pkgs.fetchurl {
      url    = "mirror://pypi/r/rainbowstream/${name}.tar.gz";
      sha256 = "0zpi1x3b535pwx8rkq57nnrb5d5ma65vvlalar9vi6ilp124x1w2";
    };

    patches = [
      ../development/python-modules/rainbowstream/image.patch
    ];

    postPatch = ''
      clib=$out/${python.sitePackages}/rainbowstream/image.so
      substituteInPlace rainbowstream/c_image.py \
        --replace @CLIB@ $clib
      sed -i 's/requests.*"/requests"/' setup.py
    '';

    LC_ALL="en_US.UTF-8";

    postInstall = ''
      mkdir -p $out/lib
      cc -fPIC -shared -o $clib rainbowstream/image.c
      for prog in "$out/bin/"*; do
        wrapProgram "$prog" \
          --prefix PYTHONPATH : "$PYTHONPATH"
      done
    '';

    buildInputs = with self; [
      pkgs.libjpeg pkgs.freetype pkgs.zlib pkgs.glibcLocales
      pillow twitter pyfiglet requests arrow dateutil pysocks
      pocket
    ];

    meta = {
      description = "Streaming command-line twitter client";
      homepage    = "http://www.rainbowstream.org/";
      license     = licenses.mit;
      maintainers = with maintainers; [ thoughtpolice ];
    };
  };

  pendulum = callPackage ../development/python-modules/pendulum { };

  pocket = buildPythonPackage rec {
    name = "pocket-${version}";
    version = "0.3.6";

    src = pkgs.fetchurl {
      url    = "mirror://pypi/p/pocket/${name}.tar.gz";
      sha256 = "1fc9vc5nyzf1kzmnrs18dmns7nn8wjfrg7br1w4c5sgs35mg2ywh";
    };

    buildInputs = with self; [
      requests
    ];

    meta = {
      description = "Wrapper for the pocket API";
      homepage    = "https://github.com/tapanpandita/pocket";
      license     = licenses.bsd3;
      maintainers = with maintainers; [ ericsagnes ];
    };
  };

  mistune = callPackage ../development/python-modules/mistune { };

  brotlipy = callPackage ../development/python-modules/brotlipy { };

  sortedcontainers = buildPythonPackage rec {
    name = "sortedcontainers-${version}";
    version = "1.5.7";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/sortedcontainers/${name}.tar.gz";
      sha256 = "1sjh8lccbmvwna91mlhl5m3z4320p07h063b8x8br4p4cll49w0g";
    };

    # tries to run tests for all python versions and uses virtualenv weirdly
    doCheck = false;
    #buildInputs = with self; [ tox nose ];

    meta = {
      description = "Python Sorted Container Types: SortedList, SortedDict, and SortedSet";
      homepage = "http://www.grantjenks.com/docs/sortedcontainers/";
      license = licenses.asl20;
    };
  };

  sortedcollections = buildPythonPackage rec {
    name = "sortedcollections-${version}";
    version = "0.4.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/sortedcollections/${name}.tar.gz";
      sha256 = "12dlzln9gyv8smsy2k6d6dmr0ywrpwyrr1cjy649ia5h1g7xdvwa";
    };
    buildInputs = [ self.sortedcontainers ];

    # wants to test all python versions with tox:
    doCheck = false;

    meta = {
      description = "Python Sorted Collections";
      homepage = http://www.grantjenks.com/docs/sortedcollections/;
      license = licenses.asl20;
    };
  };

  hyperframe = callPackage ../development/python-modules/hyperframe { };

  h2 = callPackage ../development/python-modules/h2 { };

  editorconfig = buildPythonPackage rec {
    name = "EditorConfig-${version}";
    version = "0.12.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/e/editorconfig/${name}.tar.gz";
      sha256 = "1qxqy9wfrpb2ldrk5nzidkpymc55lpf9lg3m8c8a5531jmbwhlwb";
    };

    meta = {
      description = "EditorConfig File Locator and Interpreter for Python";
      homepage = "http://editorconfig.org/";
      license = licenses.psfl;
    };
  };

  mock = buildPythonPackage (rec {
    name = "mock-2.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mock/${name}.tar.gz";
      sha256 = "1flbpksir5sqrvq2z0dp8sl4bzbadg21sj4d42w3klpdfvgvcn5i";
    };

    buildInputs = with self; [ unittest2 ];
    propagatedBuildInputs = with self; [ funcsigs six pbr ];

    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';

    meta = {
      description = "Mock objects for Python";
      homepage = http://python-mock.sourceforge.net/;
      license = stdenv.lib.licenses.bsd2;
    };
  });

  modestmaps = buildPythonPackage rec {
    name = "ModestMaps-1.4.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/M/ModestMaps/${name}.tar.gz";
      sha256 = "0vyi1m9q4pc34i6rq5agb4x3qicx5sjlbxwmxfk70k2l5mnbjca3";
    };

    disabled = !isPy27;
    propagatedBuildInputs = with self; [ pillow ];

    meta = {
      description = "A library for building interactive maps";
      homepage = http://modestmaps.com;
      license = stdenv.lib.licenses.bsd3;
    };
  };

  # Needed here because moinmoin is loaded as a Python library.
  moinmoin = callPackage ../development/python-modules/moinmoin { };

  moretools = callPackage ../development/python-modules/moretools { };

  moto = callPackage ../development/python-modules/moto {};

  mox = buildPythonPackage rec {
    name = "mox-0.5.3";

    src = pkgs.fetchurl {
      url = "http://pymox.googlecode.com/files/${name}.tar.gz";
      sha256 = "4d18a4577d14da13d032be21cbdfceed302171c275b72adaa4c5997d589a5030";
    };

    # error: invalid command 'test'
    doCheck = false;

    meta = {
      homepage = http://code.google.com/p/pymox/;
      description = "A mock object framework for Python";
    };
  };

  mozsvc = buildPythonPackage rec {
    name = "mozsvc-${version}";
    version = "0.8";

    src = pkgs.fetchgit {
      url = https://github.com/mozilla-services/mozservices.git;
      rev = "refs/tags/${version}";
      sha256 = "1zci2ikk83mf7va88c83dr6snfh4ddjqw0lsg3y29qk5nxf80vx2";
    };

    patches = singleton (pkgs.fetchurl {
      url = https://github.com/nbp/mozservices/commit/f86c0b0b870cd8f80ce90accde9e16ecb2e88863.diff;
      sha256 = "1lnghx821f6dqp3pa382ka07cncdz7hq0mkrh44d0q3grvrlrp9n";
    });

    doCheck = false; # lazy packager
    propagatedBuildInputs = with self; [ pyramid simplejson konfig ];

    meta = {
      homepage = https://github.com/mozilla-services/mozservices;
      description = "Various utilities for Mozilla apps";
    };
  };

  mpmath = buildPythonPackage rec {
    name = "mpmath-0.19";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mpmath/${name}.tar.gz";
      sha256 = "08ijsr4ifrqv3cjc26mkw0dbvyygsa99in376hr4b96ddm1gdpb8";
    };

    meta = {
      homepage    = http://mpmath.googlecode.com;
      description = "A pure-Python library for multiprecision floating arithmetic";
      license     = licenses.bsd3;
      maintainers = with maintainers; [ lovek323 ];
      platforms   = platforms.unix;
    };

    # error: invalid command 'test'
    doCheck = false;
  };


  mpd = buildPythonPackage rec {
    name = "python-mpd-0.3.0";

    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-mpd/python-mpd-0.3.0.tar.gz";
      sha256 = "02812eba1d2e0f46e37457f5a6fa23ba203622e4bcab0a19b265e66b08cd21b4";
    };

    meta = with pkgs.stdenv.lib; {
      description = "An MPD (Music Player Daemon) client library written in pure Python";
      homepage = http://jatreuman.indefero.net/p/python-mpd/;
      license = licenses.gpl3;
    };
  };

  mpd2 = buildPythonPackage rec {
    name = "mpd2-${version}";
    version = "0.5.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-mpd2/python-mpd2-${version}.tar.bz2";
      sha256 = "1gfrxf71xll1w6zb69znqg5c9j0g7036fsalkvqprh2id640cl3a";
    };

    buildInputs = with self; [ mock ];
    patchPhase = ''
      sed -i -e '/tests_require/d' \
          -e 's/cmdclass.*/test_suite="mpd_test",/' setup.py
    '';

    meta = {
      description = "A Python client module for the Music Player Daemon";
      homepage = "https://github.com/Mic92/python-mpd2";
      license = licenses.lgpl3Plus;
      maintainers = with maintainers; [ rvl mic92 ];
    };
  };

  mpv = buildPythonPackage rec {
    name = "mpv-0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mpv/${name}.tar.gz";
      sha256 = "0b9kd70mshdr713f3l1lbnz1q0vlg2y76h5d8liy1bzqm7hjcgfw";
    };
    buildInputs = [ pkgs.mpv ];
    patchPhase = "substituteInPlace mpv.py --replace libmpv.so ${pkgs.mpv}/lib/libmpv.so";

    meta = with pkgs.stdenv.lib; {
      description = "A python interface to the mpv media player";
      homepage = "https://github.com/jaseg/python-mpv";
      license = licenses.agpl3;
    };

  };


  mrbob = buildPythonPackage rec {
    name = "mrbob-${version}";
    version = "0.1.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mr.bob/mr.bob-${version}.tar.gz";
      sha256 = "6737eaf98aaeae85e07ebef844ee5156df2f06a8b28d7c3dcb056f811c588121";
    };

    buildInputs = [ pkgs.glibcLocales self.mock ];

    disabled = isPy3k;

    LC_ALL="en_US.UTF-8";

    propagatedBuildInputs = with self; [ argparse jinja2 six ] ++
                            (optionals isPy26 [ importlib ordereddict ]);

    meta = {
      homepage = https://github.com/domenkozar/mr.bob.git;
      description = "A tool to generate code skeletons from templates";
    };
  };

  msgpack = callPackage ../development/python-modules/msgpack {};

  msgpack-numpy = callPackage ../development/python-modules/msgpack-numpy {};

  msgpack-python = self.msgpack.overridePythonAttrs {
    pname = "msgpack-python";
    postPatch = ''
      substituteInPlace setup.py --replace "TRANSITIONAL = False" "TRANSITIONAL = True"
    '';
  };

  msrplib = buildPythonPackage rec {
    pname = "python-msrplib";
    name = "${pname}-${version}";
    version = "0.19";

    src = pkgs.fetchdarcs {
      url = "http://devel.ag-projects.com/repositories/${pname}";
      rev = "release-${version}";
      sha256 = "0jqvvssbwzq7bwqn3wrjfnpj8zb558mynn2visnlrcma6b57yhwd";
    };

    propagatedBuildInputs = with self; [ eventlib application gnutls ];
  };

  multipledispatch = callPackage ../development/python-modules/multipledispatch { };

  multiprocess = buildPythonPackage rec {
    name = "multiprocess-${version}";
    version = "0.70.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/multiprocess/${name}.tgz";
      sha256 = "73f8b9b7009860e3c3c8b9bdcad7e8366b130929775f89c114d4346a9cfcb31b";
    };

    propagatedBuildInputs = with self; [ dill ];

    # Python-version dependent tests
    doCheck = false;

    meta = {
      description = "Better multiprocessing and multithreading in python";
      homepage = https://github.com/uqfoundation;
      license = licenses.bsd3;
    };
  };

  munkres = buildPythonPackage rec {
    name = "munkres-1.0.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/munkres/${name}.tar.gz";
      sha256 = "c78f803b9b776bfb20a25c9c7bb44adbf0f9202c2024d51aa5969d21e560208d";
    };

    # error: invalid command 'test'
    doCheck = false;

    meta = {
      homepage = http://bmc.github.com/munkres/;
      description = "Munkres algorithm for the Assignment Problem";
      license = licenses.bsd3;
      maintainers = with maintainers; [ domenkozar ];
    };
  };


  musicbrainzngs = buildPythonPackage rec {
    name = "musicbrainzngs-0.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/musicbrainzngs/${name}.tar.gz";
      sha256 = "281388ab750d2996e9feca4580fd4215d616a698e02cd6719cb9b8562945c489";
    };

    buildInputs = [ pkgs.glibcLocales ];

    LC_ALL="en_US.UTF-8";

    meta = {
      homepage = http://alastair/python-musicbrainz-ngs;
      description = "Python bindings for musicbrainz NGS webservice";
      license = licenses.bsd2;
      maintainers = with maintainers; [ domenkozar ];
    };
  };

  mutag = buildPythonPackage rec {
    disabled = ! isPy3k;
    name = "mutag-0.0.2-2ffa0258ca";
    src = pkgs.fetchgit {
      url = "https://github.com/aroig/mutag.git";
      sha256 = "0axdnwdypfd74a9dnw0g25m16xx1yygyl828xy0kpj8gyqdc6gb1";
      rev = "2ffa0258cadaf79313241f43bf2c1caaf197d9c2";
    };

    propagatedBuildInputs = with self; [ pyparsing ];

    meta = {
      homepage = https://github.com/aroig/mutag;
      license = licenses.gpl3;
      maintainers = with maintainers; [ ];
    };
  };

  mutagen = buildPythonPackage (rec {
    name = "mutagen-1.36";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mutagen/${name}.tar.gz";
      sha256 = "1kabb9b81hgvpd3wcznww549vss12b1xlvpnxg1r6n4c7gikgvnp";
    };

    # Needed for tests only
    buildInputs = with self; [ pkgs.faad2 pkgs.flac pkgs.vorbis-tools pkgs.liboggz
      pkgs.glibcLocales pytest
    ];
    LC_ALL = "en_US.UTF-8";

    meta = {
      description = "Python multimedia tagging library";
      homepage = http://code.google.com/p/mutagen;
      license = licenses.lgpl2;
    };
  });


  muttils = buildPythonPackage (rec {
    name = "muttils-1.3";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = http://www.blacktrash.org/hg/muttils/archive/8bb26094df06.tar.bz2;
      sha256 = "1a4kxa0fpgg6rdj5p4kggfn8xpniqh8v5kbiaqc6wids02m7kag6";
    };

    # Tests don't work
    doCheck = false;

    meta = {
      description = "Utilities for use with console mail clients, like mutt";
      homepage = http://www.blacktrash.org/hg/muttils;
      license = licenses.gpl2Plus;
    };
  });

  mygpoclient = callPackage ../development/python-modules/mygpoclient { };

  mysqlclient = callPackage ../development/python-modules/mysqlclient { };

  mwclient = buildPythonPackage rec {
    version = "0.8.3";
    pname = "mwclient";
    name = "${pname}-${version}";

    src = pkgs.fetchFromGitHub {
      owner = "mwclient";
      repo = "mwclient";
      rev = "v${version}";
      sha256 = "0kl1yp9z5f1wl6lkm0vix87zkrbl9wcmkrrj1x5c35xvf95laf53";
    };

    buildInputs = with self; [ mock responses pytestcov pytest pytestcache pytestpep8 coverage ];

    propagatedBuildInputs = with self; [ six requests requests_oauthlib ];

    checkPhase = ''
      py.test
    '';

    meta = {
      description = "Python client library to the MediaWiki API";
      maintainers = with maintainers; [ ];
      license = licenses.mit;
      homepage = https://github.com/mwclient/mwclient;
    };
  };

  neuronpy = buildPythonPackage rec {
    name = "neuronpy-${version}";
    version = "0.1.6";
    disabled = !isPy27;

    propagatedBuildInputs = with self; [ numpy matplotlib scipy ];

    meta = {
      description = "Interfaces and utilities for the NEURON simulator and analysis of neural data";
      maintainers = [ maintainers.nico202 ];
      license = licenses.mit;
    };

    #No tests included
    doCheck = false;

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/source/n/neuronpy/neuronpy-${version}.tar.gz";
      sha256 = "1clhc2b5fy2l8nfrji4dagmj9419nj6kam090yqxhq5c28sngk25";
    };
  };

  pint = buildPythonPackage rec {
    name = "pint-${version}";
    version = "0.7.2";

    meta = {
      description = "Physical quantities module";
      license = licenses.bsd3;
      homepage = "https://github.com/hgrecco/pint/";
    };

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pint/Pint-${version}.tar.gz";
      sha256 = "1bbp5s34gcb9il2wyz4spznshahwbjvwi5bhjm7bnxk358spvf9q";
    };
  };

  pygal = buildPythonPackage rec {
    pname = "pygal";
    version = "2.3.1";
    name = "${pname}-${version}";

    doCheck = !isPyPy;  # one check fails with pypy

    src = fetchPypi {
      inherit pname version;
      sha256 = "7ba5a191233d0c2d8bf4b4d26b06e42bd77483a59ba7d3e5b884d81d1a870667";
    };

    buildInputs = with self; [ flask pyquery pytest ];
    propagatedBuildInputs = with self; [ cairosvg tinycss cssselect ] ++ optionals (!isPyPy) [ lxml ];

    meta = {
      description = "Sexy and simple python charting";
      homepage = http://www.pygal.org;
      license = licenses.lgpl3;
      maintainers = with maintainers; [ sjourdois ];
    };
  };

  pyte = callPackage ../development/python-modules/pyte { };

  graphviz = buildPythonPackage rec {
    name = "graphviz-${version}";
    version = "0.5.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/g/graphviz/${name}.zip";
      sha256 = "0jh31nlm0qbxwylhdkwnb69pcjlc5z03fcfbs0gvgzp3hfrngsk0";
    };

    propagatedBuildInputs = [ pkgs.graphviz ];

    meta = {
      description = "Simple Python interface for Graphviz";
      homepage = https://github.com/xflr6/graphviz;
      license = licenses.mit;
    };
  };

  pygraphviz = callPackage ../development/python-modules/pygraphviz { };

  pympler = buildPythonPackage rec {
    pname = "Pympler";
    version = "0.4.3";
    name = "${pname}-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/${pname}/${name}.tar.gz";
      sha256 = "0mhyxqlkha98y8mi5zqcjg23r30mgdjdzs05lghbmqfdyvzjh1a3";
    };

  # Remove test asizeof.flatsize(), broken and can be missed as
  # test is only useful on python 2.5, see https://github.com/pympler/pympler/issues/22
   patchPhase = ''
     substituteInPlace ./test/asizeof/test_asizeof.py --replace "n, e = test_flatsize" "#n, e = test_flatsize"
     substituteInPlace ./test/asizeof/test_asizeof.py --replace "self.assert_(n," "#self.assert_(n,"
     substituteInPlace ./test/asizeof/test_asizeof.py --replace "self.assert_(not e" "#self.assert_(not e"
    '';

    doCheck = stdenv.hostPlatform.isLinux;

    meta = {
      description = "Tool to measure, monitor and analyze memory behavior";
      homepage = http://pythonhosted.org/Pympler/;
      license = licenses.asl20;
    };
  };

  pymysql = buildPythonPackage rec {
    name = "pymysql-${version}";
    version = "0.6.6";
    src = pkgs.fetchgit {
      url = https://github.com/PyMySQL/PyMySQL.git;
      rev = "refs/tags/pymysql-${version}";
      sha256 = "0kpw11rxpyyhs9b139hxhbnx9n5kzjjw10wgwvhnf9m3mv7j4n71";
    };

    buildInputs = with self; [ unittest2 ];

    checkPhase = ''
      ${python.interpreter} runtests.py
    '';

    # Wants to connect to MySQL
    doCheck = false;
  };

  pymysqlsa = self.buildPythonPackage rec {
    name = "pymysqlsa-${version}";
    version = "1.0";

    propagatedBuildInputs = with self; [ pymysql sqlalchemy ];

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pymysql_sa/pymysql_sa-1.0.tar.gz";
      sha256 = "a2676bce514a29b2d6ab418812259b0c2f7564150ac53455420a20bd7935314a";
    };

    meta = {
      description = "PyMySQL dialect for SQL Alchemy";
      homepage = https://pypi.python.org/pypi/pymysql_sa;
      license = licenses.mit;
    };
  };

  monotonic = buildPythonPackage rec {
    pname = "monotonic";
    version = "1.3";
    name = "${pname}-${version}";

    __propagatedImpureHostDeps = stdenv.lib.optional stdenv.isDarwin "/usr/lib/libc.dylib";

    src = fetchPypi {
      inherit pname version;
      sha256 = "06vw7jwq96106plhlc5vz1v1xvjismdgw9wjyzvzf0ylglnrwiib";
    };

    patchPhase = optionalString stdenv.isLinux ''
      substituteInPlace monotonic.py --replace \
        "ctypes.util.find_library('c')" "'${stdenv.glibc.out}/lib/libc.so.6'"
    '';
  };

  MySQL_python = buildPythonPackage rec {
    name = "MySQL-python-1.2.5";

    disabled = isPy3k;

    # plenty of failing tests
    doCheck = false;

    src = pkgs.fetchurl {
      url = "mirror://pypi/M/MySQL-python/${name}.zip";
      sha256 = "0x0c2jg0bb3pp84njaqiic050qkyd7ymwhfvhipnimg58yv40441";
    };

    buildInputs = with self; [ nose ];

    propagatedBuildInputs = with self; [ pkgs.mysql.connector-c ];

    meta = {
      description = "MySQL database binding for Python";

      homepage = https://sourceforge.net/projects/mysql-python;
    };
  };

  mysql-connector = callPackage ../development/python-modules/mysql-connector { };

  namebench = buildPythonPackage (rec {
    name = "namebench-1.3.1";
    disabled = isPy3k || isPyPy;

    src = pkgs.fetchurl {
      url = "http://namebench.googlecode.com/files/${name}-source.tgz";
      sha256 = "09clbcd6wxgk4r6qw7hb78h818mvca7lijigy1mlq5y1f3lgkk1h";
    };

    # error: invalid command 'test'
    doCheck = false;

    propagatedBuildInputs = [ self.tkinter ];

    # namebench expects to be run from its own source tree (it uses relative
    # paths to various resources), make it work.
    postInstall = ''
      sed -i "s|import os|import os; os.chdir(\"$out/namebench\")|" "$out/bin/namebench.py"
    '';

    meta = {
      homepage = http://namebench.googlecode.com/;
      description = "Find fastest DNS servers available";
      license = with licenses; [
        asl20
        # third-party program licenses (embedded in the sources)
        "LGPL" # Crystal_Clear
        free # dns
        asl20 # graphy
        "BSD" # jinja2
      ];
      longDescription = ''
        It hunts down the fastest DNS servers available for your computer to
        use. namebench runs a fair and thorough benchmark using your web
        browser history, tcpdump output, or standardized datasets in order
        to provide an individualized recommendation. namebench is completely
        free and does not modify your system in any way.
      '';
    };
  });


  nameparser = buildPythonPackage rec {
    name = "nameparser-${version}";
    version = "0.3.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nameparser/${name}.tar.gz";
      sha256 = "1zi94m99ziwwd6kkip3w2xpnl05r2cfv9iq68inz7np81c3g8vag";
    };

    meta = {
      description = "A simple Python module for parsing human names into their individual components";
      homepage = https://github.com/derek73/python-nameparser;
      license = licenses.lgpl21Plus;
    };
  };

  nbconvert = callPackage ../development/python-modules/nbconvert { };

  nbformat = callPackage ../development/python-modules/nbformat { };

  nbmerge = callPackage ../development/python-modules/nbmerge { };

  nbxmpp = callPackage ../development/python-modules/nbxmpp { };

  sleekxmpp = buildPythonPackage rec {
    name = "sleekxmpp-${version}";
    version = "1.3.3";

    propagatedBuildInputs = with self; [ dnspython pyasn1 gevent ];
    checkInputs = [ pkgs.gnupg ];
    checkPhase = "${python.interpreter} testall.py";
    doCheck = false; # Tests failed all this time and upstream doesn't seem to care.

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/sleekxmpp/${name}.tar.gz";
      sha256 = "0samiq1d97kk8g9pszfbrbfw9zc41zp6017dbkwha9frf7gc24yj";
    };

    meta = {
      description = "XMPP library for Python";
      license = licenses.mit;
      homepage = http://sleekxmpp.com/;
    };
  };

  slixmpp = buildPythonPackage rec {
    name = "slixmpp-${version}";
    version = "1.2.4.post1";

    disabled = pythonOlder "3.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/s/slixmpp/${name}.tar.gz";
      sha256 = "0v6430dczai8a2nmznhja2dxl6pxa8c5j20nhc5737bqjg7245jk";
    };

    patchPhase = ''
      substituteInPlace slixmpp/thirdparty/gnupg.py \
        --replace "gpgbinary='gpg'" "gpgbinary='${pkgs.gnupg1}/bin/gpg'"
    '';

    propagatedBuildInputs = with self ; [ aiodns pyasn1 pkgs.gnupg1 pyasn1-modules];

    meta = {
      description = "Elegant Python library for XMPP";
      license = licenses.mit;
      homepage = https://dev.louiz.org/projects/slixmpp;
    };
  };

  netaddr = buildPythonPackage rec {
    pname = "netaddr";
    version = "0.7.19";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "38aeec7cdd035081d3a4c306394b19d677623bf76fa0913f6695127c7753aefd";
    };

    LC_ALL = "en_US.UTF-8";
    buildInputs = with self; [ pkgs.glibcLocales pytest ];

    checkPhase = ''
      py.test netaddr/tests
    '';

    patches = [
      (pkgs.fetchpatch {
        url = https://github.com/drkjam/netaddr/commit/2ab73f10be7069c9412e853d2d0caf29bd624012.patch;
        sha256 = "0s1cdn9v5alpviabhcjmzc0m2pnpq9dh2fnnk2x96dnry1pshg39";
      })
    ];

    meta = {
      homepage = https://github.com/drkjam/netaddr/;
      description = "A network address manipulation library for Python";
    };
  };

  netifaces = buildPythonPackage rec {
    version = "0.10.6";
    name = "netifaces-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/netifaces/${name}.tar.gz";
      sha256 = "1q7bi5k2r955rlcpspx4salvkkpk28jky67fjbpz2dkdycisak8c";
    };

    meta = {
      homepage = http://alastairs-place.net/projects/netifaces/;
      description = "Portable access to network interfaces from Python";
    };
  };

  hpack = buildPythonPackage rec {
    name = "hpack-${version}";
    version = "2.3.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/h/hpack/hpack-${version}.tar.gz";
      sha256 = "1ad0fx4d7a52zf441qzhjc7vwy9v3qdrk1zyf06ikz8y2nl9mgai";
    };

    meta = with stdenv.lib; {
      description = "========================================";
      homepage = "http://hyper.rtfd.org";
    };
  };

  nevow = callPackage ../development/python-modules/nevow { };

  nibabel = callPackage ../development/python-modules/nibabel {};

  nilearn = callPackage ../development/python-modules/nilearn {};

  nimfa = callPackage ../development/python-modules/nimfa {};

  nipy = buildPythonPackage rec {
    version = "0.4.0";
    name = "nipy-${version}";

    disabled = pythonOlder "2.6";

    checkPhase = ''    # wants to be run in a different directory
      mkdir nosetests
      cd nosetests
      ${python.interpreter} -c "import nipy; nipy.test()"
      rm -rf .
    '';
    # failing test:
    # nipy.algorithms.statistics.models.tests.test_olsR.test_results(11.593139639404727, 11.593140144880794, 6)  # disagrees by 1 at 6th decimal place
    # erroring tests:
    # nipy.modalities.fmri.fmristat.tests.test_FIAC.test_altprotocol
    # nipy.modalities.fmri.fmristat.tests.test_FIAC.test_agreement
    # nipy.tests.test_scripts.test_nipy_4d_realign   # because `nipy_4d_realign` script isn't found at test time; works from nix-shell, so could be patched
    # nipy.tests.test_scripts.test_nipy_3_4d         # ditto re.: `nipy_3_4d` script
    doCheck = false;

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nipy/${name}.tar.gz";
      sha256 = "1hnbn2i4fjxflaaz082s2c57hfp59jfra1zayz1iras5p2dy21nr";
    };

    buildInputs = stdenv.lib.optional doCheck [ self.nose ];

    propagatedBuildInputs = with self; [
      matplotlib
      nibabel
      numpy
      scipy
      sympy
    ];

    meta = {
      homepage = http://nipy.org/nipy/;
      description = "Software for structural and functional neuroimaging analysis";
      license = licenses.bsd3;
    };
  };

  nipype = callPackage ../development/python-modules/nipype {
    inherit (pkgs) which;
  };

  nose = buildPythonPackage rec {
    version = "1.3.7";
    name = "nose-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nose/${name}.tar.gz";
      sha256 = "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98";
    };

    propagatedBuildInputs = [ self.coverage ];

    doCheck = false;  # lot's of transient errors, too much hassle
    checkPhase = if python.is_py3k or false then ''
      ${python}/bin/${python.executable} setup.py build_tests
    '' else "" + ''
      rm functional_tests/test_multiprocessing/test_concurrent_shared.py* # see https://github.com/nose-devs/nose/commit/226bc671c73643887b36b8467b34ad485c2df062
      ${python}/bin/${python.executable} selftest.py
    '';

    meta = {
      description = "A unittest-based testing framework for python that makes writing and running tests easier";
    };
  };

  nose-exclude = callPackage ../development/python-modules/nose-exclude { };

  nose2 = if isPy26 then null else (buildPythonPackage rec {
    name = "nose2-0.5.0";
    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nose2/${name}.tar.gz";
      sha256 = "0595rh6b6dncbj0jigsyrgrh6h8fsl6w1fr69h76mxv9nllv0rlr";
    };
    meta = {
      description = "nose2 is the next generation of nicer testing for Python";
    };
    propagatedBuildInputs = with self; [ six ];
    # AttributeError: 'module' object has no attribute 'collector'
    doCheck = false;
  });

  nose-cover3 = buildPythonPackage rec {
    name = "nose-cover3-${version}";
    version = "0.1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nose-cover3/${name}.tar.gz";
      sha256 = "1la4hhc1yszjpcchvkqk5xmzlb2g1b3fgxj9wwc58qc549whlcc1";
    };

    propagatedBuildInputs = with self; [ nose ];

    # No tests included
    doCheck = false;

    meta = {
      description = "Coverage 3.x support for Nose";
      homepage = https://github.com/ask/nosecover3;
      license = licenses.lgpl21;
    };
  };

  nosexcover = buildPythonPackage (rec {
    name = "nosexcover-1.0.10";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nosexcover/${name}.tar.gz";
      sha256 = "f5b3a7c936c4f703f15418c1f325775098184b69fa572f868edb8a99f8f144a8";
    };

    propagatedBuildInputs = with self; [ coverage nose ];

    meta = {
      description = "Extends nose.plugins.cover to add Cobertura-style XML reports";

      homepage = https://github.com/cmheisel/nose-xcover/;

      license = licenses.bsd3;
    };
  });

  nosejs = buildPythonPackage {
    name = "nosejs-0.9.4";
    src = pkgs.fetchurl {
      url = mirror://pypi/N/NoseJS/NoseJS-0.9.4.tar.gz;
      sha256 = "0qrhkd3sga56qf6k0sqyhwfcladwi05gl6aqmr0xriiq1sgva5dy";
    };
    buildInputs = with self; [ nose ];

    checkPhase = ''
      nosetests -v
    '';

  };

  nose-cprof = buildPythonPackage rec {
    name = "nose-cprof-${version}";
    version = "0.1.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nose-cprof/${name}.tar.gz";
      sha256 = "0ayy5mbjly9aa9dkgpz0l06flspnxmnj6wxdl6zr59byrrr8fqhw";
    };

    meta = {
      description = "A python nose plugin to profile using cProfile rather than the default Hotshot profiler";
    };

    buildInputs = with self; [ nose ];
  };

  nose_warnings_filters = callPackage ../development/python-modules/nose_warnings_filters { };

  notebook = callPackage ../development/python-modules/notebook { };

  notify = pkgs.stdenv.mkDerivation (rec {
    name = "python-notify-0.1.1";

    src = pkgs.fetchurl {
      url = http://www.galago-project.org/files/releases/source/notify-python/notify-python-0.1.1.tar.bz2;
      sha256 = "1kh4spwgqxm534qlzzf2ijchckvs0pwjxl1irhicjmlg7mybnfvx";
    };

    patches = singleton (pkgs.fetchurl {
      name = "libnotify07.patch";
      url = "http://src.fedoraproject.org/cgit/notify-python.git/plain/"
          + "libnotify07.patch?id2=289573d50ae4838a1658d573d2c9f4c75e86db0c";
      sha256 = "1lqdli13mfb59xxbq4rbq1f0znh6xr17ljjhwmzqb79jl3dig12z";
    });

    postPatch = ''
      sed -i -e '/^PYGTK_CODEGEN/s|=.*|="${self.pygtk}/bin/pygtk-codegen-2.0"|' \
        configure
    '';

    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with self; [ python pkgs.libnotify pygobject2 pygtk pkgs.glib pkgs.gtk2 pkgs.dbus-glib ];

    postInstall = "cd $out/lib/python*/site-packages && ln -s gtk-*/pynotify .";

    meta = {
      description = "Python bindings for libnotify";
      homepage = http://www.galago-project.org/;
    };
  });

  notify2 = callPackage ../development/python-modules/notify2 {};

  notmuch = buildPythonPackage rec {
    name = "python-${pkgs.notmuch.name}";

    src = pkgs.notmuch.src;

    sourceRoot = pkgs.notmuch.pythonSourceRoot;

    buildInputs = with self; [ python pkgs.notmuch ];

    postPatch = ''
      sed -i -e '/CDLL/s@"libnotmuch\.@"${pkgs.notmuch}/lib/libnotmuch.@' \
        notmuch/globals.py
    '';

    meta = {
      description = "A Python wrapper around notmuch";
      homepage = http://notmuchmail.org/;
      maintainers = with maintainers; [ garbas ];
    };
  };

  emoji = callPackage ../development/python-modules/emoji { };

  ntfy = buildPythonPackage rec {
    version = "1.2.0";
    name = "ntfy-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "dschep";
      repo = "ntfy";
      rev = "v${version}";
      sha256 = "0yjxwisxpxy3vpnqk9nw5k3db3xx6wyf6sk1px9m94s30glcq2cc";
    };

    propagatedBuildInputs = with self; [ appdirs pyyaml requests dbus-python emoji sleekxmpp mock ];

    meta = {
      description = "A utility for sending notifications, on demand and when commands finish";
      homepage = http://ntfy.rtfd.org/;
      license = licenses.gpl3;
      maintainers = with maintainers; [ kamilchm ];
    };
  };

  ntplib = buildPythonPackage rec {
    name = "ntplib-0.3.3";
    src = pkgs.fetchurl {
      url = mirror://pypi/n/ntplib/ntplib-0.3.3.tar.gz;
      sha256 = "c4621b64d50be9461d9bd9a71ba0b4af06fbbf818bbd483752d95c1a4e273ede";
    };

    # Require networking
    doCheck = false;

    meta = {
      description = "Python NTP library";
      license = licenses.mit;
    };
  };

  numba = callPackage ../development/python-modules/numba { };

  numexpr = callPackage ../development/python-modules/numexpr { };

  Nuitka = let
    # scons is needed but using it requires Python 2.7
    # Therefore we create a separate env for it.
    scons = pkgs.python27.withPackages(ps: [ pkgs.scons ]);
  in buildPythonPackage rec {
    version = "0.5.25";
    name = "Nuitka-${version}";

    # Latest version is not yet on PyPi
    src = pkgs.fetchurl {
      url = "https://github.com/kayhayen/Nuitka/archive/${version}.tar.gz";
      sha256 = "11psz0pyj56adv4b3f47hl8jakvp2mc2c85s092a5rsv1la1a0aa";
    };

    buildInputs = with self; stdenv.lib.optionals doCheck [ vmprof pyqt4 ];

    propagatedBuildInputs = [ scons ];

    postPatch = ''
      patchShebangs tests/run-tests
    '' + stdenv.lib.optionalString stdenv.isLinux ''
      substituteInPlace nuitka/plugins/standard/ImplicitImports.py --replace 'locateDLL("uuid")' '"${pkgs.utillinux.out}/lib/libuuid.so"'
    '';

    # We do not want any wrappers here.
    postFixup = '''';

    checkPhase = ''
      tests/run-tests
    '';

    # Problem with a subprocess (parts)
    doCheck = false;

    # Requires CPython
    disabled = isPyPy;

    meta = {
      description = "Python compiler with full language support and CPython compatibility";
      license = licenses.asl20;
      homepage = http://nuitka.net/;
    };
  };

  numpy = callPackage ../development/python-modules/numpy {
    blas = pkgs.openblasCompat;
  };

  numpydoc = callPackage ../development/python-modules/numpydoc { };

  numpy-stl = callPackage ../development/python-modules/numpy-stl { };

  numtraits = callPackage ../development/python-modules/numtraits { };

  nwdiag = callPackage ../development/python-modules/nwdiag { };

  dynd = buildPythonPackage rec {
    version = "0.7.2";
    name = "dynd-${version}";
    disabled = isPyPy;

    src = pkgs.fetchFromGitHub {
      owner = "libdynd";
      repo = "dynd-python";
      rev = "v${version}";
      sha256 = "19igd6ibf9araqhq9bxmzbzdz05vp089zxvddkiik3b5gb7l17nh";
    };

    # setup.py invokes git on build but we're fetching a tarball, so
    # can't retrieve git version. We hardcode:
    preConfigure = ''
      substituteInPlace setup.py --replace "ver = check_output(['git', 'describe', '--dirty'," "ver = '${version}'"
      substituteInPlace setup.py --replace "'--always', '--match', 'v*']).decode('ascii').strip('\n')" ""
    '';

    # Python 3 works but has a broken import test that I couldn't
    # figure out.
    doCheck = !isPy3k;
    buildInputs = with pkgs; [ cmake libdynd.dev self.cython ];
    propagatedBuildInputs = with self; [ numpy pkgs.libdynd ];

    meta = {
      homepage = http://libdynd.org;
      license = licenses.bsd2;
      description = "Python exposure of dynd";
      maintainers = with maintainers; [ teh ];
    };
  };

  livestreamer = buildPythonPackage rec {
    version = "1.12.2";
    name = "livestreamer-${version}";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "https://github.com/chrippa/livestreamer/archive/v${version}.tar.gz";
      sha256 = "1fp3d3z2grb1ls97smjkraazpxnvajda2d1g1378s6gzmda2jvjd";
    };

    buildInputs = [ pkgs.makeWrapper ];

    propagatedBuildInputs = with self; [ pkgs.rtmpdump pycrypto requests ]
      ++ optionals isPy26 [ singledispatch futures argparse ]
      ++ optionals isPy27 [ singledispatch futures ]
      ++ optionals isPy33 [ singledispatch ];

    postInstall = ''
      wrapProgram $out/bin/livestreamer --prefix PATH : ${pkgs.rtmpdump}/bin
    '';

    meta = {
      homepage = http://livestreamer.tanuki.se;
      description = ''
        Livestreamer is CLI program that extracts streams from various
        services and pipes them into a video player of choice.
      '';
      license = licenses.bsd2;
      maintainers = with maintainers; [ fuuzetsu ];
    };
  };

  livestreamer-curses = buildPythonPackage rec {
    version = "1.5.2";
    name = "livestreamer-curses-${version}";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "https://github.com/gapato/livestreamer-curses/archive/v${version}.tar.gz";
      sha256 = "1v49sym6mrci9dxy0a7cpbp4bv6fg2ijj6rwk4wzg18c2x4qzkhn";
    };

    propagatedBuildInputs = with self; [ livestreamer ];

    meta = {
      homepage = https://github.com/gapato/livestreamer-curses;
      description = "Curses frontend for livestreamer";
      license = licenses.mit;
    };
  };

  oauth = buildPythonPackage (rec {
    name = "oauth-1.0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/o/oauth/oauth-1.0.1.tar.gz";
      sha256 = "0pdgi35hczsslil4890xqawnbpdazkgf2v1443847h5hy2gq2sg7";
    };

    # No tests included in archive
    doCheck = false;

    meta = {
      homepage = http://code.google.com/p/oauth;
      description = "Library for OAuth version 1.0a";
      license = licenses.mit;
      platforms = platforms.all;
    };
  });

  oauth2 = buildPythonPackage (rec {
    name = "oauth2-${version}";
    version = "1.9.0.post1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/o/oauth2/${name}.tar.gz";
      sha256 = "c006a85e7c60107c7cc6da1b184b5c719f6dd7202098196dfa6e55df669b59bf";
    };

    propagatedBuildInputs = with self; [ httplib2 ];

    buildInputs = with self; [ mock coverage ];

    # ServerNotFoundError: Unable to find the server at oauth-sandbox.sevengoslings.net
    doCheck = false;

    meta = {
      homepage = "https://github.com/simplegeo/python-oauth2";
      description = "Library for OAuth version 1.0";
      license = licenses.mit;
      maintainers = with maintainers; [ garbas ];
      platforms = platforms.linux;
    };
  });

  oauth2client = buildPythonPackage rec {
    name = "oauth2client-1.4.12";

    src = pkgs.fetchurl {
      url = "mirror://pypi/o/oauth2client/${name}.tar.gz";
      sha256 = "0phfk6s8bgpap5xihdk1xv2lakdk1pb3rg6hp2wsg94hxcxnrakl";
    };

    propagatedBuildInputs = with self; [ six httplib2 pyasn1-modules rsa ];
    doCheck = false;

    meta = {
      description = "A client library for OAuth 2.0";
      homepage = https://github.com/google/oauth2client/;
      license = licenses.bsd2;
    };
  };

  oauthlib = buildPythonPackage rec {
    version = "2.0.0";
    name = "oauthlib-${version}";

    src = pkgs.fetchurl {
      url = "https://github.com/idan/oauthlib/archive/v${version}.tar.gz";
      sha256 = "02b645a8rqh4xfs1cmj8sss8wqppiadd1ndq3av1cdjz2frfqcjf";
    };

    buildInputs = with self; [ mock nose unittest2 ];

    propagatedBuildInputs = with self; [ cryptography blinker pyjwt ];

    meta = {
      homepage = https://github.com/idan/oauthlib;
      downloadPage = https://github.com/idan/oauthlib/releases;
      description = "A generic, spec-compliant, thorough implementation of the OAuth request-signing logic";
      maintainers = with maintainers; [ prikhi ];
    };
  };


  obfsproxy = buildPythonPackage ( rec {
    name = "obfsproxy-${version}";
    version = "0.2.13";

    src = pkgs.fetchgit {
      url = meta.repositories.git;
      rev = "refs/tags/${name}";
      sha256 = "04ja1cl8xzqnwrd2gi6nlnxbmjri141bzwa5gybvr44d8h3k2nfa";
    };

    postPatch = ''
      substituteInPlace setup.py --replace "version=versioneer.get_version()" "version='${version}'"
      substituteInPlace setup.py --replace "argparse" ""
    '';

    propagatedBuildInputs = with self;
      [ pyptlib argparse twisted pycrypto pyyaml ];

    # No tests in archive
    doCheck = false;

    meta = {
      description = "A pluggable transport proxy";
      homepage = https://www.torproject.org/projects/obfsproxy;
      repositories.git = https://git.torproject.org/pluggable-transports/obfsproxy.git;
      maintainers = with maintainers; [ phreedom thoughtpolice ];
    };
  });

  objgraph = buildPythonPackage rec {
    name = "objgraph-${version}";
    version = "2.0.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/o/objgraph/${name}.tar.gz";
      sha256 = "841de52715774ec1d0e97d9b4462d6e3e10406155f9b61f54ba7db984c45442a";
    };

    # Tests fail with PyPy.
    disabled = isPyPy;

    propagatedBuildInputs = with self; [pkgs.graphviz];

    meta = {
      description = "Draws Python object reference graphs with graphviz";
      homepage = http://mg.pov.lt/objgraph/;
      license = licenses.mit;
    };
  };

  odo = callPackage ../development/python-modules/odo { };

  offtrac = buildPythonPackage rec {
    name = "offtrac-0.1.0";
    meta.maintainers = with maintainers; [ ];

    src = pkgs.fetchurl {
      url = "mirror://pypi/o/offtrac/${name}.tar.gz";
      sha256 = "06vd010pa1z7lyfj1na30iqzffr4kzj2k2sba09spik7drlvvl56";
    };
    doCheck = false;
  };

  openpyxl = callPackage ../development/python-modules/openpyxl { };

  opentimestamps = callPackage ../development/python-modules/opentimestamps { };

  ordereddict = buildPythonPackage rec {
    name = "ordereddict-${version}";
    version = "1.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/o/ordereddict/${name}.tar.gz";
      sha256 = "07qvy11nvgxpzarrni3wrww3vpc9yafgi2bch4j2vvvc42nb8d8w";
    };

    meta = {
      description = "A drop-in substitute for Py2.7's new collections.OrderedDict that works in Python 2.4-2.6";
      license = licenses.bsd3;
      maintainers = with maintainers; [ garbas ];
    };
  };

  python-otr = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "python-otr";
    version = "1.2.0";

    disabled = isPy3k;

    src = pkgs.fetchFromGitHub {
      owner = "AGProjects";
      repo = pname;
      rev = "release-" + version;
      sha256 = "0p3b1n8jlxwd65gbk2k5007fkhdyjwcvr4982s42hncivxvabzzy";
    };

    propagatedBuildInputs = with self; [ zope_interface cryptography application gmpy2 ];

    meta = {
      description = "A pure python implementation of OTR";
      homepage = https://github.com/AGProjects/otr;
      license = licenses.lgpl21Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ edwtjo ];
    };
  };

  plone-testing = callPackage ../development/python-modules/plone-testing { };

  ply = buildPythonPackage (rec {
    name = "ply-3.8";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/ply/${name}.tar.gz";
      sha256 = "e7d1bdff026beb159c9942f7a17e102c375638d9478a7ecd4cc0c76afd8de0b8";
    };

    checkPhase = ''
      ${python.interpreter} test/testlex.py
      ${python.interpreter} test/testyacc.py
    '';

    # Test suite appears broken
    doCheck = false;

    meta = {
      homepage = http://www.dabeaz.com/ply/;

      description = "PLY (Python Lex-Yacc), an implementation of the lex and yacc parsing tools for Python";

      longDescription = ''
        PLY is an implementation of lex and yacc parsing tools for Python.
        In a nutshell, PLY is nothing more than a straightforward lex/yacc
        implementation.  Here is a list of its essential features: It's
        implemented entirely in Python; It uses LR-parsing which is
        reasonably efficient and well suited for larger grammars; PLY
        provides most of the standard lex/yacc features including support for
        empty productions, precedence rules, error recovery, and support for
        ambiguous grammars; PLY is straightforward to use and provides very
        extensive error checking; PLY doesn't try to do anything more or less
        than provide the basic lex/yacc functionality.  In other words, it's
        not a large parsing framework or a component of some larger system.
      '';

      license = licenses.bsd3;

      maintainers = [ ];
    };
  });

  plyvel = buildPythonPackage (rec {
    name = "plyvel-0.9";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/plyvel/${name}.tar.gz";
      sha256 = "1scq75qyks9vmjd19bx57f2y60mkdr44ajvb12p3cjg439l96zaq";
    };

    buildInputs = with self; [ pkgs.leveldb ]
                            ++ optional isPy3k pytest;

    # no tests for python2
    doCheck = isPy3k;

    meta = {
      description = "Fast and feature-rich Python interface to LevelDB";
      homepage = https://github.com/wbolster/plyvel;
      license = licenses.bsd3;
    };
  });

  osc = buildPythonPackage {
    name = "osc-0.159.0-4-g2d44589";
    disabled = isPy3k;
    src = pkgs.fetchFromGitHub {
      owner = "openSUSE";
      repo = "osc";
      rev = "2d44589886845af7da911aaec9403344e396cd91";
      sha256 = "0s8p7gkp64w6r5rnxpbvl2dgb5p85kq2skcqm6qxn5ddadhw2sfz";
    };
    buildInputs = with pkgs; [ bashInteractive ]; # needed for bash-completion helper
    propagatedBuildInputs = with self; [ urlgrabber m2crypto pyyaml ];
    postInstall = ''
      ln -s $out/bin/osc-wrapper.py $out/bin/osc
      install -D -m444 osc.fish $out/etc/fish/completions/osc.fish
      install -D -m555 dist/osc.complete $out/share/bash-completion/helpers/osc-helper
      mkdir -p $out/share/bash-completion/completions
      cat >>$out/share/bash-completion/completions/osc <<EOF
      test -z "\$BASH_VERSION" && return
      complete -o default _nullcommand >/dev/null 2>&1 || return
      complete -r _nullcommand >/dev/null 2>&1         || return
      complete -o default -C $out/share/bash-completion/helpers/osc-helper osc
      EOF
    '';
    meta = {
      description = "opensuse-commander with svn like handling";
      maintainers = [ maintainers.peti ];
      license = licenses.gpl2;
    };
  };

  rfc3986 = callPackage ../development/python-modules/rfc3986 { };

   cachetools_1 = callPackage ../development/python-modules/cachetools/1.nix {};
   cachetools = callPackage ../development/python-modules/cachetools {};

  cmd2 = callPackage ../development/python-modules/cmd2 {};

 warlock = buildPythonPackage rec {
   name = "warlock-${version}";
   version = "1.2.0";

   src = pkgs.fetchurl {
     url = "mirror://pypi/w/warlock/${name}.tar.gz";
     sha256 = "0npgi4ks0nww2d6ci791iayab0j6kz6dx3jr7bhpgkql3s4if3bw";
   };

   propagatedBuildInputs = with self; [
     six jsonpatch jsonschema jsonpointer
   ];
   buildInputs = with self; [

   ];

   meta = with stdenv.lib; {
     homepage = "http://github.com/bcwaldon/warlock";
   };
 };


  pecan = callPackage ../development/python-modules/pecan { };

  kaitaistruct = callPackage ../development/python-modules/kaitaistruct { };

  Kajiki = buildPythonPackage rec {
    name = "Kajiki-${version}";
    version = "0.5.5";

    src = pkgs.fetchurl {
      url = "mirror://pypi/K/Kajiki/${name}.tar.gz";
      sha256 = "effcae388e25c3358eb0bbd733448509d11a1ec500e46c69241fc673021f0517";
    };

    propagatedBuildInputs = with self; [
      Babel pytz nine
    ];
    meta = with stdenv.lib; {
      description = "Kajiki provides fast well-formed XML templates";
      homepage = "https://github.com/nandoflorestan/kajiki";
    };
  };

  WSME = buildPythonPackage rec {
    name = "WSME-${version}";
    version = "0.8.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/W/WSME/${name}.tar.gz";
      sha256 = "1nw827iz5g9jlfnfbdi8kva565v0kdjzba2lccziimj09r71w900";
    };

    checkPhase = ''
      # remove turbogears tests as we don't have it packaged
      rm tests/test_tg*
      # remove flask since we don't have flask-restful
      rm tests/test_flask*
      # https://bugs.launchpad.net/wsme/+bug/1510823
      ${if isPy3k then "rm tests/test_cornice.py" else ""}

      nosetests tests/
    '';

    propagatedBuildInputs = with self; [
      pbr six simplegeneric netaddr pytz webob
    ];
    buildInputs = with self; [
      cornice nose webtest pecan transaction cherrypy sphinx
    ];
  };


  zake = buildPythonPackage rec {
    name = "zake-${version}";
    version = "0.2.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/z/zake/${name}.tar.gz";
      sha256 = "1rp4xxy7qp0s0wnq3ig4ji8xsl31g901qkdp339ndxn466cqal2s";
    };

    propagatedBuildInputs = with self; [ kazoo six ];
    buildInputs = with self; [ testtools ];
    checkPhase = ''
      ${python.interpreter} -m unittest discover zake/tests
    '';

    meta = with stdenv.lib; {
      homepage = "https://github.com/yahoo/Zake";
    };
  };

  kazoo = buildPythonPackage rec {
    name = "kazoo-${version}";
    version = "2.2.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/k/kazoo/${name}.tar.gz";
      sha256 = "10pb864if9qi2pq9lfb9m8f7z7ss6rml80gf1d9h64lap5crjnjj";
    };

    propagatedBuildInputs = with self; [
      six
    ];
    buildInputs = with self; [
      eventlet gevent nose mock coverage pkgs.openjdk8
    ];

    # not really needed
    preBuild = ''
      sed -i '/flake8/d' setup.py
    '';

    preCheck = ''
      sed -i 's/test_unicode_auth/noop/' kazoo/tests/test_client.py
    '';

    # tests take a long time to run and leave threads hanging
    doCheck = false;
    #ZOOKEEPER_PATH = "${pkgs.zookeeper}";

    meta = with stdenv.lib; {
      homepage = "https://kazoo.readthedocs.org";
    };
  };

  FormEncode = callPackage ../development/python-modules/FormEncode { };

  pycountry = buildPythonPackage rec {
    name = "pycountry-${version}";
    version = "1.17";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pycountry/${name}.tar.gz";
      sha256 = "1qvhq0c9xsh6d4apcvjphfzl6xnwhnk4jvhr8x2fdfnmb034lc26";
    };
  };

  nine = buildPythonPackage rec {
    name = "nine-${version}";
    version = "0.3.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/n/nine/${name}.tar.gz";
      sha256 = "1zrsbm0hajfvklkhgysp81hy632a3bdakp31m0lcpd9xbp5265zy";
    };

    meta = with stdenv.lib; {
      description = "Let's write Python 3 right now!";
      homepage = "https://github.com/nandoflorestan/nine";
    };
  };


  logutils = buildPythonPackage rec {
    name = "logutils-${version}";
    version = "0.3.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/l/logutils/${name}.tar.gz";
      sha256 = "173w55fg3hp5dhx7xvssmgqkcv5fjlaik11w5dah2fxygkjvhhj0";
    };
  };

  ldappool = callPackage ../development/python-modules/ldappool { };

  lz4 = buildPythonPackage rec {
    name = "lz4-0.8.2";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/b5/f0/e1de2bb7feb54011f3c4dcf35b7cca3536e19526764db051b50ea26b58e7/lz4-0.8.2.tar.gz";
      sha256 = "1irad4sq4hdr30fr53smvv3zzk4rddcf9b4jx19w8s9xsxhr1x3b";
    };

    buildInputs= with self; [ nose ];

    meta = with stdenv.lib; {
      description = "Compression library";
      homepage = https://github.com/python-lz4/python-lz4;
      license = licenses.bsd3;
    };
  };

 retrying = buildPythonPackage rec {
    name = "retrying-${version}";
    version = "1.3.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/retrying/retrying-1.3.3.tar.gz";
      sha256 = "0fwp86xv0rvkncjdvy2mwcvbglw4w9k0fva25i7zx8kd19b3kh08";
    };

    propagatedBuildInputs = with self; [ six ];

    # doesn't ship tests in tarball
    doCheck = false;

    meta = with stdenv.lib; {
      homepage = https://github.com/rholder/retrying;
    };
  };

  fasteners = buildPythonPackage rec {
    name = "fasteners-${version}";
    version = "0.14.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/f/fasteners/${name}.tar.gz";
      sha256 = "063y20kx01ihbz2mziapmjxi2cd0dq48jzg587xdsdp07xvpcz22";
    };

    propagatedBuildInputs = with self; [ six monotonic testtools ];

    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';
    # Tests are written for Python 3.x only (concurrent.futures)
    doCheck = isPy3k;


    meta = with stdenv.lib; {
      description = "Fasteners";
      homepage = https://github.com/harlowja/fasteners;
    };
  };

  aioeventlet = buildPythonPackage rec {
    name = "aioeventlet-${version}";
    version = "0.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/a/aioeventlet/aioeventlet-0.4.tar.gz";
      sha256 = "19krvycaiximchhv1hcfhz81249m3w3jrbp2h4apn1yf4yrc4y7y";
    };

    propagatedBuildInputs = with self; [ eventlet trollius asyncio ];
    buildInputs = with self; [ mock ];

    # 2 tests error out
    doCheck = false;
    checkPhase = ''
      ${python.interpreter} runtests.py
    '';

    meta = with stdenv.lib; {
      description = "aioeventlet implements the asyncio API (PEP 3156) on top of eventlet. It makes";
      homepage = http://aioeventlet.readthedocs.org/;
    };
  };

  olefile = callPackage ../development/python-modules/olefile { };

  requests-mock = buildPythonPackage rec {
    name = "requests-mock-${version}";
    version = "1.3.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/requests-mock/${name}.tar.gz";
      sha256 = "0jr997dvk6zbmhvbpcv3rajrgag69mcsm1ai3w3rgk2jdh6rg1mx";
    };

    patchPhase = ''
      sed -i 's@python@${python.interpreter}@' .testr.conf
    '';

    buildInputs = with self; [ pbr testtools testrepository mock ];
    propagatedBuildInputs = with self; [ six requests ];
  };

  mox3 = buildPythonPackage rec {
    name = "mox3-${version}";
    version = "0.23.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mox3/${name}.tar.gz";
      sha256 = "0q26sg0jasday52a7y0cch13l0ssjvr4yqnvswqxsinj1lv5ld88";
    };

    patchPhase = ''
      sed -i 's@python@${python.interpreter}@' .testr.conf
    '';

    #  FAIL: mox3.tests.test_mox.RegexTest.testReprWithFlags
    #  ValueError: cannot use LOCALE flag with a str pattern
    doCheck = !isPy36;

    buildInputs = with self; [ subunit testrepository testtools six ];
    propagatedBuildInputs = with self; [ pbr fixtures ];
  };

  doc8 = callPackage ../development/python-modules/doc8 { };

  wrapt = callPackage ../development/python-modules/wrapt { };

  pagerduty = buildPythonPackage rec {
    name = "pagerduty-${version}";
    version = "0.2.1";
    disabled = isPy3k;

    src = pkgs.fetchurl {
        url = "mirror://pypi/p/pagerduty/pagerduty-${version}.tar.gz";
        sha256 = "e8c237239d3ffb061069aa04fc5b3d8ae4fb0af16a9713fe0977f02261d323e9";
    };
  };

  pandas = callPackage ../development/python-modules/pandas { };

  pandas_0_17_1 = callPackage ../development/python-modules/pandas/0.17.1.nix { };

  xlrd = buildPythonPackage rec {
    name = "xlrd-${version}";

    version = "0.9.4";
    src = pkgs.fetchurl {
      url = "mirror://pypi/x/xlrd/xlrd-${version}.tar.gz";
      sha256 = "8e8d3359f39541a6ff937f4030db54864836a06e42988c452db5b6b86d29ea72";
    };

    buildInputs = with self; [ nose ];
    checkPhase = ''
      nosetests -v
    '';

  };

  bottleneck = callPackage ../development/python-modules/bottleneck { };

  paho-mqtt = buildPythonPackage rec {
    name = "paho-mqtt-${version}";
    version = "1.1";

    disabled = isPyPy || isPy26;

    src = pkgs.fetchurl {
        url = "mirror://pypi/p/paho-mqtt/${name}.tar.gz";
        sha256 = "07i6k9mw66kgbvjgsrcsd2sjji9ckym50dcxnmhjqfkfzsg64yhg";
    };

    meta = {
      homepage = "https://eclipse.org/paho/";
      description = "mqtt library for machine to machine and internet of things";
      license = licenses.epl10;
      maintainers = with maintainers; [ mog ];
    };
  };

  pamqp = buildPythonPackage rec {
    version = "1.6.1";
    name = "pamqp-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pamqp/${name}.tar.gz";
      sha256 = "1vmyvynqzx5zvbipaxff4fnzy3h3dvl3zicyr15yb816j93jl2ca";
    };

    buildInputs = with self; [ mock nose pep8 pylint mccabe ];

    meta = {
      description = "RabbitMQ Focused AMQP low-level library";
      homepage = https://pypi.python.org/pypi/pamqp;
      license = licenses.bsd3;
    };
  };

  parsedatetime = buildPythonPackage rec {
    name = "parsedatetime-${version}";
    version = "2.3";

    meta = {
      description = "Parse human-readable date/time text";
      homepage = "https://github.com/bear/parsedatetime";
      license = licenses.asl20;
    };

    buildInputs = with self; [ pytest pytestrunner ];
    propagatedBuildInputs = with self; [ future ];

    src = pkgs.fetchurl {
        url = "mirror://pypi/p/parsedatetime/${name}.tar.gz";
        sha256 = "1vkrmd398s11h1zn3zaqqsiqhj9lwy1ikcg6irx2lrgjzjg3rjll";
    };
  };

  paramiko = buildPythonPackage rec {
    pname = "paramiko";
    version = "2.1.1";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0xdmamqgx2ymhdm46q8flpj4fncj4wv2dqxzz0bc2dh7mnkss7fm";
    };

    propagatedBuildInputs = with self; [ cryptography pyasn1 ];

    __darwinAllowLocalNetworking = true;

    # https://github.com/paramiko/paramiko/issues/449
    doCheck = !(isPyPy || isPy33);
    checkPhase = ''
      # test_util needs to resolve an hostname, thus failing when the fw blocks it
      sed '/UtilTest/d' -i test.py

      ${python}/bin/${python.executable} test.py --no-sftp --no-big-file
    '';

    meta = {
      homepage = "https://github.com/paramiko/paramiko/";
      description = "Native Python SSHv2 protocol library";
      license = licenses.lgpl21Plus;
      maintainers = with maintainers; [ aszlig ];

      longDescription = ''
        This is a library for making SSH2 connections (client or server).
        Emphasis is on using SSH2 as an alternative to SSL for making secure
        connections between python scripts. All major ciphers and hash methods
        are supported. SFTP client and server mode are both supported too.
      '';
    };
  };

  parameterized = callPackage ../development/python-modules/parameterized { };

  paramz = callPackage ../development/python-modules/paramz { };

  parsel = buildPythonPackage rec {
    name = "parsel-${version}";
    version = "1.1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/parsel/${name}.tar.gz";
      sha256 = "0a34d1c0bj1fzb5dk5744m2ag6v3b8glk4xp0amqxdan9ldbcd97";
    };

    buildInputs = with self; [ pytest pytestrunner ];
    propagatedBuildInputs = with self; [ six w3lib lxml cssselect ];

    checkPhase = ''
      py.test
    '';

    meta = {
      homepage = "https://github.com/scrapy/parsel";
      description = "Parsel is a library to extract data from HTML and XML using XPath and CSS selectors";
      license = licenses.bsd3;
    };
  };

  parso = callPackage ../development/python-modules/parso { };

  partd = callPackage ../development/python-modules/partd { };

  patch = buildPythonPackage rec {
    name = "${pname}-${version}";
    version = "1.16";
    pname = "patch";

    src = pkgs.fetchzip {
      url = "mirror://pypi/p/${pname}/${name}.zip";
      sha256 = "1nj55hvyvzax4lxq7vkyfbw91pianzr3hp7ka7j12pgjxccac50g";
      stripRoot = false;
    };

    # No tests included in archive
    doCheck = false;

    meta = {
      description = "A library to parse and apply unified diffs";
      homepage = https://github.com/techtonik/python-patch/;
      license = licenses.mit;
      platforms = platforms.all;
      maintainers = [ maintainers.igsha ];
    };
  };

  pathos = buildPythonPackage rec {
    name = "pathos-${version}";
    version = "0.2.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pathos/${name}.tgz";
      sha256 = "e35418af733bf434da83746d46acca94375d6e306b3df330b2a1808db026a188";
    };

    propagatedBuildInputs = with self; [ dill pox ppft multiprocess ];

    # Require network
    doCheck = false;

    meta = {
      description = "Parallel graph management and execution in heterogeneous computing";
      homepage = http://www.cacr.caltech.edu/~mmckerns/pathos.htm;
      license = licenses.bsd3;
    };
  };

  patsy = buildPythonPackage rec {
    name = "patsy-${version}";
    version = "0.3.0";

    src = pkgs.fetchurl{
      url = "mirror://pypi/p/patsy/${name}.zip";
      sha256 = "a55dd4ca09af4b9608b81f30322beb450510964c022708ab50e83a065ccf15f0";
    };

    buildInputs = with self; [ nose ];
    propagatedBuildInputs = with self; [six numpy];

    meta = {
      description = "A Python package for describing statistical models";
      homepage = "https://github.com/pydata/patsy";
      license = licenses.bsd2;
    };
  };

  paste = buildPythonPackage rec {
    name = "paste-${version}";
    version = "2.0.3";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/Paste/Paste-${version}.tar.gz";
      sha256 = "062jk0nlxf6lb2wwj6zc20rlvrwsnikpkh90y0dn8cjch93s6ii3";
    };

    checkInputs = with self; [ nose ];
    propagatedBuildInputs = with self; [ six ];

    # Certain tests require network
    checkPhase = ''
      NOSE_EXCLUDE=test_ok,test_form,test_error,test_stderr,test_paste_website nosetests
    '';

    meta = {
      description = "Tools for using a Web Server Gateway Interface stack";
      homepage = http://pythonpaste.org/;
    };
  };


  PasteDeploy = buildPythonPackage rec {
    version = "1.5.2";
    name = "paste-deploy-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/PasteDeploy/PasteDeploy-${version}.tar.gz";
      sha256 = "d5858f89a255e6294e63ed46b73613c56e3b9a2d82a42f1df4d06c8421a9e3cb";
    };

    buildInputs = with self; [ nose ];

    meta = {
      description = "Load, configure, and compose WSGI applications and servers";
      homepage = http://pythonpaste.org/deploy/;
      platforms = platforms.all;
    };
  };

   pasteScript = buildPythonPackage rec {
    version = "1.7.5";
    name = "PasteScript-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/PasteScript/${name}.tar.gz";
      sha256 = "2b685be69d6ac8bc0fe6f558f119660259db26a15e16a4943c515fbee8093539";
    };

    doCheck = false;
    buildInputs = with self; [ nose ];
    propagatedBuildInputs = with self; [ six paste PasteDeploy cheetah argparse ];

    meta = {
      description = "A pluggable command-line frontend, including commands to setup package file layouts";
      homepage = http://pythonpaste.org/script/;
      platforms = platforms.all;
    };
  };

  patator = callPackage ../development/python-modules/patator { };

  pathlib = buildPythonPackage rec {
    name = "pathlib-${version}";
    version = "1.0.1";
    disabled = pythonAtLeast "3.4"; # Was added to std library in Python 3.4

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pathlib/${name}.tar.gz";
      sha256 = "17zajiw4mjbkkv6ahp3xf025qglkj0805m9s41c45zryzj6p2h39";
    };

    checkPhase = ''
      ${python.interpreter} -m unittest discover
    '';

    meta = {
      description = "Object-oriented filesystem paths";
      homepage = "https://pathlib.readthedocs.org/";
      license = licenses.mit;
    };
  };

  pathlib2 = callPackage ../development/python-modules/pathlib2 { };

  pathpy = callPackage ../development/python-modules/path.py { };

  paypalrestsdk = callPackage ../development/python-modules/paypalrestsdk { };

  pbr = callPackage ../development/python-modules/pbr { };

  fixtures = callPackage ../development/python-modules/fixtures { };

  pelican = callPackage ../development/python-modules/pelican {
    inherit (pkgs) glibcLocales pandoc git;
  };

  pep8 = buildPythonPackage rec {
    name = "pep8-${version}";
    version = "1.7.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pep8/${name}.tar.gz";
      sha256 = "a113d5f5ad7a7abacef9df5ec3f2af23a20a28005921577b15dd584d099d5900";
    };

    meta = {
      homepage = "http://pep8.readthedocs.org/";
      description = "Python style guide checker";
      license = licenses.mit;
      maintainers = with maintainers; [ garbas ];
    };
  };

  pep257 = callPackage ../development/python-modules/pep257 { };

  percol = buildPythonPackage rec {
    name = "percol-${version}";
    version = "0.0.8";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/percol/${name}.tar.gz";
      sha256 = "169s5mhw1s60qbsd6pkf9bb2x6wfgx8hn8nw9d4qgc68qnnpp2cj";
    };

    propagatedBuildInputs = with self; [ ];

    meta = {
      homepage = https://github.com/mooz/percol;
      description = "Adds flavor of interactive filtering to the traditional pipe concept of shell";
      license = licenses.mit;
      maintainers = with maintainers; [ koral ];
    };
  };

  pexif = buildPythonPackage rec {
    name = "pexif-${version}";
    version = "0.15";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pexif/pexif-0.15.tar.gz";
      sha256 = "45a3be037c7ba8b64bbfc48f3586402cc17de55bb9d7357ef2bc99954a18da3f";
    };

    meta = {
      description = "A module for editing JPEG EXIF data";
      homepage = http://www.benno.id.au/code/pexif/;
      license = licenses.mit;
    };
  };

  pexpect = callPackage ../development/python-modules/pexpect { };

  pdfkit = buildPythonPackage rec {
    name = "pdfkit-${version}";
    version = "0.5.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pdfkit/${name}.zip";
      sha256 = "1p1m6gp51ql3wzjs2iwds8sc3hg1i48yysii9inrky6qc3s6q5vf";
    };

    buildInputs = with self; [ ];
    # tests are not distributed
    doCheck = false;

    meta = {
      homepage = https://pypi.python.org/pypi/pdfkit;
      description = "Wkhtmltopdf python wrapper to convert html to pdf using the webkit rendering engine and qt";
      license = licenses.mit;
    };
  };

  pg8000 = buildPythonPackage rec {
    name = "pg8000-1.10.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pg8000/${name}.tar.gz";
      sha256 = "188658db63c2ca931ae1bf0167b34efaac0ecc743b707f0118cc4b87e90ce488";
    };

    propagatedBuildInputs = with self; [ pytz ];

    meta = {
      maintainers = with maintainers; [ garbas domenkozar ];
      platforms = platforms.linux;
    };
  };

  pgspecial = buildPythonPackage rec {
    pname = "pgspecial";
    version = "1.8.0";
    name = "${pname}-${version}";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1dwlv3m4jl34zsakmvxg6hgbfv786jl8dcffxsrlnmcpks829xc9";
    };

    buildInputs = with self; [ pytest psycopg2 ];

    checkPhase = ''
      find tests -name \*.pyc -delete
      py.test tests
    '';

    propagatedBuildInputs = with self; [ click sqlparse ];

    meta = {
      description = "Meta-commands handler for Postgres Database";
      homepage = https://pypi.python.org/pypi/pgspecial;
      license = licenses.bsd3;
    };
  };

  pickleshare = buildPythonPackage rec {
    version = "0.7.4";
    name = "pickleshare-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pickleshare/${name}.tar.gz";
      sha256 = "84a9257227dfdd6fe1b4be1319096c20eb85ff1e82c7932f36efccfe1b09737b";
    };

    propagatedBuildInputs = with self; [pathpy] ++ optional (pythonOlder "3.4") pathlib2;

    # No proper test suite
    doCheck = false;

    meta = {
      description = "Tiny 'shelve'-like database with concurrency support";
      homepage = https://github.com/vivainio/pickleshare;
      license = licenses.mit;
    };
  };

  piep = buildPythonPackage rec {
    version = "0.8.0";
    name = "piep-${version}";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/piep/piep-${version}.tar.gz";
      sha256 = "1wgkg1kc28jpya5k4zvbc9jmpa60b3d5c3gwxfbp15hw6smyqirj";
    };

    propagatedBuildInputs = with self; [pygments];

    meta = {
      description = "Bringing the power of python to stream editing";
      homepage = https://github.com/timbertson/piep;
      maintainers = with maintainers; [ timbertson ];
      license = licenses.gpl3;
    };
  };

  piexif = callPackage ../development/python-modules/piexif { };

  pip = buildPythonPackage rec {
    pname = "pip";
    version = "9.0.1";
    name = "${pname}-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/${builtins.substring 0 1 pname}/${pname}/${name}.tar.gz";
      sha256 = "09f243e1a7b461f654c26a725fa373211bb7ff17a9300058b205c61658ca940d";
    };

    # pip detects that we already have bootstrapped_pip "installed", so we need
    # to force it a little.
    installFlags = [ "--ignore-installed" ];

    checkInputs = with self; [ mock scripttest virtualenv pretend pytest ];
    # Pip wants pytest, but tests are not distributed
    doCheck = false;

    meta = {
      description = "The PyPA recommended tool for installing Python packages";
      license = licenses.mit;
      homepage = https://pip.pypa.io/;
      priority = 10;
    };
  };

  pip-tools = callPackage ../development/python-modules/pip-tools {
    git = pkgs.gitMinimal;
    glibcLocales = pkgs.glibcLocales;
  };

  pika = buildPythonPackage rec {
    name = "pika-${version}";
    version = "0.10.0";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/source/p/pika/${name}.tar.gz";
      sha256 = "0nb4h08di432lv7dy2v9kpwgk0w92f24sqc2hw2s9vwr5b8v8xvj";
    };

    # Tests require twisted which is only availalble for python-2.x
    doCheck = !isPy3k;

    buildInputs = with self; [ nose mock pyyaml unittest2 pyev ] ++ optionals (!isPy3k) [ twisted tornado ];

    meta = {
      description = "Pure-Python implementation of the AMQP 0-9-1 protocol";
      homepage = https://pika.readthedocs.org;
      license = licenses.bsd3;
    };
  };

  pika-pool = callPackage ../development/python-modules/pika-pool { };
  platformio = callPackage ../development/python-modules/platformio { };

  kmsxx = callPackage ../development/libraries/kmsxx { };

  pybase64 = callPackage ../development/python-modules/pybase64 { };

  pylibconfig2 = buildPythonPackage rec {
    name = "pylibconfig2-${version}";
    version = "0.2.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pylibconfig2/${name}.tar.gz";
      sha256 = "0kyg6gldj6hi2jhc5xhi834bb2mcaiy24dvfik963shnldqr7kqg";
    };

    doCheck = false;

    propagatedBuildInputs = with self ; [ pyparsing ];

    meta = {
      homepage = https://github.com/heinzK1X/pylibconfig2;
      description = "Pure python library for libconfig syntax";
      license = licenses.gpl3;
    };
  };

  pylibmc = callPackage ../development/python-modules/pylibmc {};

  pymetar = callPackage ../development/python-modules/pymetar { };

  pysftp = buildPythonPackage rec {
    name = "pysftp-${version}";
    version = "0.2.9";
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pysftp/${name}.tar.gz";
      sha256 = "0jl5qix5cxzrv4lb8rfpjkpcghbkacnxkb006ikn7mkl5s05mxgv";
    };

    propagatedBuildInputs = with self; [ paramiko ];

    meta = {
      homepage = https://bitbucket.org/dundeemt/pysftp;
      description = "A friendly face on SFTP";
      license = licenses.mit;
      longDescription = ''
        A simple interface to SFTP. The module offers high level abstractions
        and task based routines to handle your SFTP needs. Checkout the Cook
        Book, in the docs, to see what pysftp can do for you.
      '';
    };
  };

  pysoundfile = callPackage ../development/python-modules/pysoundfile { };

  python3pika = buildPythonPackage {
    name = "python3-pika-0.9.14";
    disabled = !isPy3k;

    # Unit tests adds dependencies on pyev, tornado and twisted (and twisted is disabled for Python 3)
    doCheck = false;

    src = pkgs.fetchurl {
      url = mirror://pypi/p/python3-pika/python3-pika-0.9.14.tar.gz;
      sha256 = "1c3hifwvn04kvlja88iawf0awyz726jynwnpcb6gn7376b4nfch7";
    };
    buildInputs = with self; [ nose mock pyyaml ];

    propagatedBuildInputs = with self; [ unittest2 ];
  };


  python-jenkins = buildPythonPackage rec {
    name = "python-jenkins-${version}";
    version = "0.4.14";
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/python-jenkins/${name}.tar.gz";
      sha256 = "1n8ikvd9jf4dlki7nqlwjlsn8wpsx4x7wg4h3d6bkvyvhwwf8yqf";
    };
    patchPhase = ''
      sed -i 's@python@${python.interpreter}@' .testr.conf
    '';

    buildInputs = with self; [ mock ];
    propagatedBuildInputs = with self; [ pbr pyyaml six multi_key_dict testtools
     testscenarios testrepository kerberos ];

    meta = {
      description = "Python bindings for the remote Jenkins API";
      homepage = https://pypi.python.org/pypi/python-jenkins;
      license = licenses.bsd3;
    };
  };

  pystringtemplate = callPackage ../development/python-modules/stringtemplate { };

  pillow = callPackage ../development/python-modules/pillow {
    inherit (pkgs) freetype libjpeg zlib libtiff libwebp tcl lcms2 tk;
    inherit (pkgs.xorg) libX11;
  };

  pkgconfig = buildPythonPackage rec {
    name = "pkgconfig-${version}";
    version = "1.1.0";

    # pypy: SyntaxError: __future__ statements must appear at beginning of file
    disabled = isPyPy;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pkgconfig/${name}.tar.gz";
      sha256 = "709daaf077aa2b33bedac12706373412c3683576a43013bbaa529fc2769d80df";
    };

    buildInputs = with self; [ nose ];

    propagatedBuildInputs = with self; [pkgs.pkgconfig];

    meta = {
      description = "Interface Python with pkg-config";
      homepage = https://github.com/matze/pkgconfig;
      license = licenses.mit;
    };

    # nosetests needs to be run explicitly.
    # Note that the distributed archive does not actually contain any tests.
    # https://github.com/matze/pkgconfig/issues/9
    checkPhase = ''
      nosetests
    '';

  };

  plumbum = callPackage ../development/python-modules/plumbum { };

  polib = callPackage ../development/python-modules/polib {};

  posix_ipc = buildPythonPackage rec {
    name = "posix_ipc-${version}";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/posix_ipc/${name}.tar.gz";
      sha256 = "1jzg66708pi5n9w07fbz6rlxx30cjds9hp2yawjjfryafh1hg4ww";
    };

    meta = {
      description = "POSIX IPC primitives (semaphores, shared memory and message queues)";
      license = licenses.bsd3;
      homepage = http://semanchuk.com/philip/posix_ipc/;
    };
  };

  portend = callPackage ../development/python-modules/portend { };

  powerline = callPackage ../development/python-modules/powerline { };

  pox = buildPythonPackage rec {
    name = "pox-${version}";
    version = "0.2.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pox/${name}.tgz";
      sha256 = "22e97ac6d2918c754e65a9581dbe02e9d00ae4a54ca48d05118f87c1ea92aa19";
    };

    meta = {
      description = "Utilities for filesystem exploration and automated builds";
      license = licenses.bsd3;
      homepage = http://www.cacr.caltech.edu/~mmckerns/pox.htm;
    };
  };

  ppft = buildPythonPackage rec {
    name = "ppft-${version}";
    version = "1.6.4.6";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/ppft/${name}.tgz";
      sha256 = "6f99c861822884cb00badbd5f364ee32b90a157084a6768040793988c6b92bff";
    };

    propagatedBuildInputs = with self; [ six ];

    meta = {
      description = "Distributed and parallel python";
      homepage = https://github.com/uqfoundation;
      license = licenses.bsd3;
    };
  };

  praw = callPackage ../development/python-modules/praw { };

  prawcore = callPackage ../development/python-modules/prawcore { };

  premailer = callPackage ../development/python-modules/premailer { };

  prettytable = buildPythonPackage rec {
    name = "prettytable-0.7.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/PrettyTable/${name}.tar.bz2";
      sha256 = "599bc5b4b9602e28294cf795733c889c26dd934aa7e0ee9cff9b905d4fbad188";
    };

    buildInputs = [ pkgs.glibcLocales ];

    preCheck = ''
      export LANG="en_US.UTF-8"
    '';

    meta = {
      description = "Simple Python library for easily displaying tabular data in a visually appealing ASCII table format";
      homepage = http://code.google.com/p/prettytable/;
    };
  };


  prompt_toolkit = callPackage ../development/python-modules/prompt_toolkit { };

  prompt_toolkit_52 = self.prompt_toolkit.overridePythonAttrs(oldAttrs: rec {
    name = "${oldAttrs.pname}-${version}";
    version = "0.52";
    src = oldAttrs.src.override {
      inherit version;
      sha256 = "00h9ldqmb33nhg2kpks7paldf3n3023ipp124alwp96yz16s7f1m";
    };

    # No tests included in archive
    doCheck = false;

    #Only <3.4 expressly supported.
    disabled = isPy35;

  });

  protobuf = callPackage ../development/python-modules/protobuf {
    disabled = isPyPy;
    doCheck = !isPy3k;
    protobuf = pkgs.protobuf;
  };

  protobuf3_1 = callPackage ../development/python-modules/protobuf {
    disabled = isPyPy;
    doCheck = !isPy3k;
    protobuf = pkgs.protobuf3_1;
  };

  psd-tools = callPackage ../development/python-modules/psd-tools { };

  psutil = callPackage ../development/python-modules/psutil { };

  psutil_1 = self.psutil.overrideAttrs (oldAttrs: rec {
    name = "${oldAttrs.pname}-${version}";
    version = "1.2.1";
    src = oldAttrs.src.override {
      inherit version;
      sha256 = "0ibclqy6a4qmkjhlk3g8jhpvnk0v9aywknc61xm3hfi5r124m3jh";
    };
  });

  psycopg2 = buildPythonPackage rec {
    name = "psycopg2-2.7.1";
    disabled = isPyPy;
    src = pkgs.fetchurl {
      url = "mirror://pypi/p/psycopg2/${name}.tar.gz";
      sha256 = "86c9355f5374b008c8479bc00023b295c07d508f7c3b91dbd2e74f8925b1d9c6";
    };
    buildInputs = optional stdenv.isDarwin pkgs.openssl;
    propagatedBuildInputs = with self; [ pkgs.postgresql ];
    doCheck = false;
    meta = {
      description = "PostgreSQL database adapter for the Python programming language";
      license = with licenses; [ gpl2 zpl20 ];
    };
  };

  ptpython = callPackage ../development/python-modules/ptpython {};

  publicsuffix = callPackage ../development/python-modules/publicsuffix {};

  py = callPackage ../development/python-modules/py { };

  pyacoustid = buildPythonPackage rec {
    name = "pyacoustid-1.1.0";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyacoustid/${name}.tar.gz";
      sha256 = "0117039cb116af245e6866e8e8bf3c9c8b2853ad087142bd0c2dfc0acc09d452";
    };

    propagatedBuildInputs = with self; [ requests audioread ];

    patches = [ ../development/python-modules/pyacoustid-py3.patch ];

    postPatch = ''
      sed -i \
          -e '/^FPCALC_COMMAND *=/s|=.*|= "${pkgs.chromaprint}/bin/fpcalc"|' \
          acoustid.py
    '';

    meta = {
      description = "Bindings for Chromaprint acoustic fingerprinting";
      homepage = "https://github.com/sampsyo/pyacoustid";
      license = licenses.mit;
    };
  };


  pyalgotrade = buildPythonPackage {
    name = "pyalgotrade-0.16";
    disabled = isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/PyAlgoTrade/PyAlgoTrade-0.16.tar.gz";
      sha256 = "a253617254194b91cfebae7bfd184cb109d4e48a8c70051b9560000a2c0f94b3";
    };

    propagatedBuildInputs = with self; [ numpy scipy pytz ];

    meta = {
      description = "Python Algorithmic Trading";
      homepage = http://gbeced.github.io/pyalgotrade/;
      license = licenses.asl20;
    };
  };


  pyasn1 = callPackage ../development/python-modules/pyasn1 { };

  pyasn1-modules = callPackage ../development/python-modules/pyasn1-modules { };

  pyaudio = buildPythonPackage rec {
    name = "python-pyaudio-${version}";
    version = "0.2.9";

    src = pkgs.fetchurl {
      url = "mirror://pypi/P/PyAudio/PyAudio-${version}.tar.gz";
      sha256 = "bfd694272b3d1efc51726d0c27650b3c3ba1345f7f8fdada7e86c9751ce0f2a1";
    };

    disabled = isPyPy;

    buildInputs = with self; [ pkgs.portaudio ];

    meta = {
      description = "Python bindings for PortAudio";
      homepage = "http://people.csail.mit.edu/hubert/pyaudio/";
      license = licenses.mit;
    };
  };

  pysam = callPackage ../development/python-modules/pysam { };

  pysaml2 = buildPythonPackage rec {
    name = "pysaml2-${version}";
    version = "3.0.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pysaml2/${name}.tar.gz";
      sha256 = "0y2iw1dddcvi13xjh3l52z1mvnrbc41ik9k4nn7lwj8x5kimnk9n";
    };

    patches = [
      (pkgs.fetchpatch {
        name = "CVE-2016-10127.patch";
        url = "https://sources.debian.net/data/main/p/python-pysaml2/3.0.0-5/debian/patches/fix-xxe-in-xml-parsing.patch";
        sha256 = "184lkwdayjqiahzsn4yp15parqpmphjsb1z7zwd636jvarxqgs2q";
      })
    ];

    propagatedBuildInputs = with self; [
      repoze_who paste cryptography pycrypto pyopenssl ipaddress six cffi idna
      enum34 pytz setuptools zope_interface dateutil requests pyasn1 webob decorator pycparser
      defusedxml
    ];
    buildInputs = with self; [
      Mako pytest memcached pymongo mongodict pkgs.xmlsec
    ];

    preConfigure = ''
      sed -i 's/pymongo==3.0.1/pymongo/' setup.py
    '';

    # 16 failed, 427 passed, 17 error in 88.85 seconds
    doCheck = false;

    meta = with stdenv.lib; {
      homepage = "https://github.com/rohe/pysaml2";
    };
  };

  python-pushover = callPackage ../development/python-modules/pushover {};

  mongodict = buildPythonPackage rec {
    name = "mongodict-${version}";
    version = "0.3.1";

    src = pkgs.fetchurl {
      url = "mirror://pypi/m/mongodict/${name}.tar.gz";
      sha256 = "0nv5amfs337m0gbxpjb0585s20rndqfc3mfrzq1iwgnds5gxcrlw";
    };

    propagatedBuildInputs = with self; [
      pymongo
    ];

    meta = with stdenv.lib; {
      description = "MongoDB-backed Python dict-like interface";
      homepage = "https://github.com/turicas/mongodict/";
    };
  };


  repoze_who = buildPythonPackage rec {
    name = "repoze.who-${version}";
    version = "2.2";

    src = pkgs.fetchurl {
      url = "mirror://pypi/r/repoze.who/${name}.tar.gz";
      sha256 = "12wsviar45nwn35w2y4i8b929dq2219vmwz8013wx7bpgkn2j9ij";
    };

    propagatedBuildInputs = with self; [
      zope_interface webob
    ];
    buildInputs = with self; [

    ];

    meta = with stdenv.lib; {
      description = "WSGI Authentication Middleware / API";
      homepage = "http://www.repoze.org";
    };
  };



  vobject = buildPythonPackage rec {
    version = "0.9.5";
    name = "vobject-${version}";

    src = pkgs.fetchFromGitHub {
      owner = "eventable";
      repo = "vobject";
      sha256 = "1f5lw9kpssr66bdirkjba3izbnm68p8pd47546m5yl4c7x76s1ld";
      rev = version;
    };

    disabled = isPyPy;

    propagatedBuildInputs = with self; [ dateutil ];

    checkPhase = "${python.interpreter} tests.py";

    meta = {
      description = "Module for reading vCard and vCalendar files";
      homepage = http://eventable.github.io/vobject/;
      license = licenses.asl20;
      maintainers = with maintainers; [ ];
    };
  };

  pycarddav = buildPythonPackage rec {
    version = "0.7.0";
    name = "pycarddav-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pyCardDAV/pyCardDAV-${version}.tar.gz";
      sha256 = "0avkrcpisfvhz103v7vmq2jd83hvmpqrb4mlbx6ikkk1wcvclsx8";
    };

    disabled = isPy3k || isPyPy;

    propagatedBuildInputs = with self; [ vobject lxml requests urwid pyxdg ];

    meta = {
      description = "Command-line interface carddav client";
      homepage = http://lostpackets.de/pycarddav;
      license = licenses.mit;
      maintainers = with maintainers; [ ];
    };
  };

  pygit2 = callPackage ../development/python-modules/pygit2 { };

  Babel = buildPythonPackage (rec {
    name = "Babel-2.3.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/B/Babel/${name}.tar.gz";
      sha256 = "0x98qqqw35xllpcama013a9788ly84z8dm1w2wwfpxh2710c8df5";
    };

    buildInputs = with self; [ pytest ];
    propagatedBuildInputs = with self; [ pytz ];

    meta = {
      homepage = http://babel.edgewall.org;
      description = "A collection of tools for internationalizing Python applications";
      license = licenses.bsd3;
      maintainers = with maintainers; [ garbas ];
    };
  });

  pybfd = callPackage ../development/python-modules/pybfd { };

  pyblock = stdenv.mkDerivation rec {
    name = "pyblock-${version}";
    version = "0.53";
    md5_path = "f6d33a8362dee358517d0a9e2ebdd044";

    src = pkgs.fetchurl rec {
      url = "http://src.fedoraproject.org/repo/pkgs/python-pyblock/"
          + "${name}.tar.bz2/${md5_path}/${name}.tar.bz2";
      sha256 = "f6cef88969300a6564498557eeea1d8da58acceae238077852ff261a2cb1d815";
    };

    postPatch = ''
      sed -i -e 's|/usr/include/python|${python}/include/python|' \
             -e 's/-Werror *//' -e 's|/usr/|'"$out"'/|' Makefile
    '';

    buildInputs = with self; [ python pkgs.lvm2 pkgs.dmraid ];

    makeFlags = [
      "USESELINUX=0"
      "SITELIB=$(out)/${python.sitePackages}"
    ];

    meta = {
      description = "Interface for working with block devices";
      license = licenses.gpl2Plus;
    };
  };

  pybcrypt = buildPythonPackage rec {
    name = "pybcrypt";
    version = "0.4";

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/py-bcrypt/py-bcrypt-${version}.tar.gz";
      sha256 = "5fa13bce551468350d66c4883694850570f3da28d6866bb638ba44fe5eabda78";
    };

    meta = {
      description = "bcrypt password hashing and key derivation";
      homepage = https://code.google.com/p/py-bcrypt2;
      license = "BSD";
    };
  };

  pyblosxom = buildPythonPackage rec {
    name = "pyblosxom-${version}";
    disabled = isPy3k;
    version = "1.5.3";
    # FAIL:test_generate_entry and test_time
    # both tests fail due to time issue that doesn't seem to matter in practice
    doCheck = false;
    src = pkgs.fetchurl {
      url = "https://github.com/pyblosxom/pyblosxom/archive/v${version}.tar.gz";
      sha256 = "0de9a7418f4e6d1c45acecf1e77f61c8f96f036ce034493ac67124626fd0d885";
    };

    propagatedBuildInputs = with self; [ pygments markdown ];

    meta = {
      homepage = "http://pyblosxom.github.io";
      description = "File-based blogging engine";
      license = licenses.mit;
    };
  };


  pycapnp = buildPythonPackage rec {
    name = "pycapnp-0.5.1";
    disabled = isPyPy || isPy3k;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pycapnp/${name}.tar.gz";
      sha256 = "1kp97il34419gcrhn866n6a10lvh8qr13bnllnnh9473n4cq0cvk";
    };

    buildInputs = with pkgs; [ capnproto self.cython ];

    # import setuptools as soon as possible, to minimize monkeypatching mayhem.
    postConfigure = ''
      sed -i '3iimport setuptools' setup.py
    '';

    meta = {
      maintainers = with maintainers; [ cstrahan ];
      license = licenses.bsd2;
      platforms = platforms.all;
      homepage = "http://jparyani.github.io/pycapnp/index.html";
    };
  };


  pycdio = buildPythonPackage rec {
    name = "pycdio-2.0.0";
    disabled = !isPy27;

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pycdio/${name}.tar.gz";
      sha256 = "1a1h0lmfl56a2a9xqhacnjclv81nv3906vdylalybxrk4bhrm3hj";
    };

    prePatch = "sed -i -e '/DRIVER_BSDI/d' pycdio.py";

    preConfigure = ''
      patchShebangs .
    '';

    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ self.setuptools self.nose pkgs.swig pkgs.libcdio ]
      ++ stdenv.lib.optional stdenv.isDarwin pkgs.libiconv;

    # Run tests using nosetests but first need to install the binaries
    # to the root source directory where they can be found.
    checkPhase = ''
      ./setup.py install_lib -d .
      nosetests
    '';

    meta = {
      homepage = http://www.gnu.org/software/libcdio/;
      description = "Wrapper around libcdio (CD Input and Control library)";
      maintainers = with maintainers; [ rycee ];
      license = licenses.gpl3Plus;
    };
  };

  pycosat = callPackage ../development/python-modules/pycosat { };

  pycryptopp = buildPythonPackage (rec {
    name = "pycryptopp-0.6.0.1206569328141510525648634803928199668821045408958";
    disabled = isPy3k || isPyPy;  # see https://bitbucket.org/pypy/pypy/issue/1190/

    src = pkgs.fetchurl {
      url = "mirror://pypi/p/pycryptopp/${name}.tar.gz";
      sha256 = "0n90h1yg7bfvlbhnc54xb6dbqm286ykaksyg04kxlhyjgf8mhq8i";
    };

    # Prefer crypto++ library from the Nix store over the one that's included
    # in the pycryptopp distribution.
    preConfigure = "export PYCRYPTOPP_DISABLE_EMBEDDED_CRYPTOPP=1";

    buildInputs = with self; [ setuptoolsDarcs darcsver pkgs.cryptopp ];

    meta = {
      homepage = http://allmydata.org/trac/pycryptopp;

      description = "Python wrappers for the Crypto++ library";

      license = licenses.gpl2Plus;

      maintainers = [ ];
      platforms = platforms.linux;
    };
  });

  pycups = callPackage ../development/python-modules/pycups { };

  pycurl = callPackage ../development/python-modules/pycurl { };

  pycurl2 = buildPythonPackage (rec {
    name = "pycurl2-7.20.0";
    disabled = isPy3k;

    src = pkgs.fetchgit {
      url = "https://github.com/Lispython/pycurl.git";
      rev = "0f00109950b883d680bd85dc6e8a9c731a7d0d13";
      sha256 = "1qmw3cm93kxj94s71a8db9lwv2cxmr2wjv7kp1r8zildwdzhaw7j";
    };

  certifi = callPackage ../development/python-modules/certifi { };

  characteristic = callPackage ../development/python-modules/characteristic { };

  cheetah = callPackage ../development/python-modules/cheetah { };

  cherrypy = callPackage ../development/python-modules/cherrypy {};

  cfgv = callPackage ../development/python-modules/cfgv { };

  cftime = callPackage ../development/python-modules/cftime {};

  cjson = callPackage ../development/python-modules/cjson { };

  cld2-cffi = callPackage ../development/python-modules/cld2-cffi {};

  clf = callPackage ../development/python-modules/clf {};

  click = callPackage ../development/python-modules/click {};

  click-completion = callPackage ../development/python-modules/click-completion {};

  click-didyoumean = callPackage ../development/python-modules/click-didyoumean {};

  click-log = callPackage ../development/python-modules/click-log {};

  click-plugins = callPackage ../development/python-modules/click-plugins {};

  click-repl = callPackage ../development/python-modules/click-repl { };

  click-threading = callPackage ../development/python-modules/click-threading {};

  cligj = callPackage ../development/python-modules/cligj { };

  closure-linter = callPackage ../development/python-modules/closure-linter { };

  cloudpickle = callPackage ../development/python-modules/cloudpickle { };

  cmdline = callPackage ../development/python-modules/cmdline { };

  codecov = callPackage ../development/python-modules/codecov {};

  cogapp = callPackage ../development/python-modules/cogapp {};

  colorama = callPackage ../development/python-modules/colorama { };

  colorlover = callPackage ../development/python-modules/colorlover { };

  CommonMark = callPackage ../development/python-modules/commonmark { };

  CommonMark_54 = self.CommonMark.overridePythonAttrs (oldAttrs: rec {
    version = "0.5.4";
    src = oldAttrs.src.override {
      inherit version;
      sha256 = "34d73ec8085923c023930dfc0bcd1c4286e28a2a82de094bb72fabcc0281cbe5";
    };
  });

  coilmq = callPackage ../development/python-modules/coilmq { };

  colander = callPackage ../development/python-modules/colander { };

  # Backported version of the ConfigParser library of Python 3.3
  configparser = callPackage ../development/python-modules/configparser { };

  ColanderAlchemy = callPackage ../development/python-modules/colanderalchemy { };

  conda = callPackage ../development/python-modules/conda { };

  configobj = callPackage ../development/python-modules/configobj { };

  confluent-kafka = callPackage ../development/python-modules/confluent-kafka {};

  kafka-python = callPackage ../development/python-modules/kafka-python {};

  construct = callPackage ../development/python-modules/construct {};

  consul = callPackage ../development/python-modules/consul { };

  contexter = callPackage ../development/python-modules/contexter { };

  contextvars = callPackage ../development/python-modules/contextvars {};

  contextlib2 = callPackage ../development/python-modules/contextlib2 { };

  cookiecutter = callPackage ../development/python-modules/cookiecutter { };

  cookies = callPackage ../development/python-modules/cookies { };

  coveralls = callPackage ../development/python-modules/coveralls { };

  coverage = callPackage ../development/python-modules/coverage { };

  covCore = callPackage ../development/python-modules/cov-core { };

  crcmod = callPackage ../development/python-modules/crcmod { };

  credstash = callPackage ../development/python-modules/credstash { };

  cython = callPackage ../development/python-modules/Cython { };

  cytoolz = callPackage ../development/python-modules/cytoolz { };

  cryptacular = callPackage ../development/python-modules/cryptacular { };

  cryptography = callPackage ../development/python-modules/cryptography { };

  cryptography_vectors = callPackage ../development/python-modules/cryptography_vectors { };

  curtsies = callPackage ../development/python-modules/curtsies { };

  envs = callPackage ../development/python-modules/envs { };

  eth-hash = callPackage ../development/python-modules/eth-hash { };

  eth-typing = callPackage ../development/python-modules/eth-typing { };

  eth-utils = callPackage ../development/python-modules/eth-utils { };

  jsonrpc-async = callPackage ../development/python-modules/jsonrpc-async { };

  jsonrpc-base = callPackage ../development/python-modules/jsonrpc-base { };

  jsonrpc-websocket = callPackage ../development/python-modules/jsonrpc-websocket { };

  onkyo-eiscp = callPackage ../development/python-modules/onkyo-eiscp { };

  pyunifi = callPackage ../development/python-modules/pyunifi { };

  tablib = callPackage ../development/python-modules/tablib { };

  wakeonlan = callPackage ../development/python-modules/wakeonlan { };

  openant = callPackage ../development/python-modules/openant { };

  opencv = toPythonModule (pkgs.opencv.override {
    enablePython = true;
    pythonPackages = self;
  });

  opencv3 = toPythonModule (pkgs.opencv3.override {
    enablePython = true;
    pythonPackages = self;
  });

  opencv4 = toPythonModule (pkgs.opencv4.override {
    enablePython = true;
    pythonPackages = self;
  });

  openidc-client = callPackage ../development/python-modules/openidc-client {};

  idna = callPackage ../development/python-modules/idna { };

  mahotas = callPackage ../development/python-modules/mahotas { };

  MDP = callPackage ../development/python-modules/mdp {};

  minidb = callPackage ../development/python-modules/minidb { };

  miniupnpc = callPackage ../development/python-modules/miniupnpc {};

  mixpanel = callPackage ../development/python-modules/mixpanel { };

  mpyq = callPackage ../development/python-modules/mpyq { };

  mxnet = callPackage ../development/python-modules/mxnet { };

  parsy = callPackage ../development/python-modules/parsy { };

  portpicker = callPackage ../development/python-modules/portpicker { };

  pkginfo = callPackage ../development/python-modules/pkginfo { };

  pretend = callPackage ../development/python-modules/pretend { };

  detox = callPackage ../development/python-modules/detox { };

  pbkdf2 = callPackage ../development/python-modules/pbkdf2 { };

  bcrypt = callPackage ../development/python-modules/bcrypt { };

  cffi = callPackage ../development/python-modules/cffi { };

  pycollada = callPackage ../development/python-modules/pycollada { };

  pycontracts = callPackage ../development/python-modules/pycontracts { };

  pycparser = callPackage ../development/python-modules/pycparser { };

  pydub = callPackage ../development/python-modules/pydub {};

  pyjade = callPackage ../development/python-modules/pyjade {};

  pyjet = callPackage ../development/python-modules/pyjet {};

  PyLD = callPackage ../development/python-modules/PyLD { };

  python-jose = callPackage ../development/python-modules/python-jose {};

  python-json-logger = callPackage ../development/python-modules/python-json-logger { };

  python-ly = callPackage ../development/python-modules/python-ly {};

  pyhepmc = callPackage ../development/python-modules/pyhepmc { };

  pytest = self.pytest_39;

  inherit (callPackage ../development/python-modules/pytest {
    # hypothesis tests require pytest that causes dependency cycle
    hypothesis = self.hypothesis.override { doCheck = false; };
  }) pytest_39 pytest_37;

  pytest-httpbin = callPackage ../development/python-modules/pytest-httpbin { };

  pytest-asyncio = callPackage ../development/python-modules/pytest-asyncio { };

  pytest-annotate = callPackage ../development/python-modules/pytest-annotate { };

  pytest-ansible = callPackage ../development/python-modules/pytest-ansible { };

  pytest-aiohttp = callPackage ../development/python-modules/pytest-aiohttp { };

  pytest-benchmark = callPackage ../development/python-modules/pytest-benchmark { };

  pytestcache = callPackage ../development/python-modules/pytestcache { };

  pytest-catchlog = callPackage ../development/python-modules/pytest-catchlog { };

  pytest-cram = callPackage ../development/python-modules/pytest-cram { };

  pytest-datafiles = callPackage ../development/python-modules/pytest-datafiles { };

  pytest-dependency = callPackage ../development/python-modules/pytest-dependency { };

  pytest-django = callPackage ../development/python-modules/pytest-django { };

  pytest-faulthandler = callPackage ../development/python-modules/pytest-faulthandler { };

  pytest-fixture-config = callPackage ../development/python-modules/pytest-fixture-config { };

  pytest-forked = callPackage ../development/python-modules/pytest-forked { };

  pytest-rerunfailures = callPackage ../development/python-modules/pytest-rerunfailures { };

  pytest-relaxed = callPackage ../development/python-modules/pytest-relaxed { };

  pytest-flake8 = callPackage ../development/python-modules/pytest-flake8 { };

  pytestflakes = callPackage ../development/python-modules/pytest-flakes { };

  pytest-isort = callPackage ../development/python-modules/pytest-isort { };

  pytest-mock = callPackage ../development/python-modules/pytest-mock { };

  pytest-timeout = callPackage ../development/python-modules/pytest-timeout { };

  pytest-warnings = callPackage ../development/python-modules/pytest-warnings { };

  pytestpep8 = callPackage ../development/python-modules/pytest-pep8 { };

  pytest-pep257 = callPackage ../development/python-modules/pytest-pep257 { };

  pytest-raisesregexp = callPackage ../development/python-modules/pytest-raisesregexp { };

  pytest-repeat = callPackage ../development/python-modules/pytest-repeat { };

  pytestrunner = callPackage ../development/python-modules/pytestrunner { };

  pytestquickcheck = callPackage ../development/python-modules/pytest-quickcheck { };

  pytest-server-fixtures = callPackage ../development/python-modules/pytest-server-fixtures { };

  pytest-shutil = callPackage ../development/python-modules/pytest-shutil { };

  pytestcov = callPackage ../development/python-modules/pytest-cov { };

  pytest-expect = callPackage ../development/python-modules/pytest-expect { };

  pytest-virtualenv = callPackage ../development/python-modules/pytest-virtualenv { };

  pytest_xdist = callPackage ../development/python-modules/pytest-xdist { };

  pytest-localserver = callPackage ../development/python-modules/pytest-localserver { };

  pytest-subtesthack = callPackage ../development/python-modules/pytest-subtesthack { };

  pytest-sugar = callPackage ../development/python-modules/pytest-sugar { };

  tinycss = callPackage ../development/python-modules/tinycss { };

  tinycss2 = callPackage ../development/python-modules/tinycss2 { };

  cssselect = callPackage ../development/python-modules/cssselect { };

  cssselect2 = callPackage ../development/python-modules/cssselect2 { };

  cssutils = callPackage ../development/python-modules/cssutils { };

  darcsver = callPackage ../development/python-modules/darcsver { };

  dask = callPackage ../development/python-modules/dask { };

  dask-glm = callPackage ../development/python-modules/dask-glm { };

  dask-image = callPackage ../development/python-modules/dask-image { };

  dask-jobqueue = callPackage ../development/python-modules/dask-jobqueue { };

  dask-ml = callPackage ../development/python-modules/dask-ml { };

  dask-xgboost = callPackage ../development/python-modules/dask-xgboost { };

  datrie = callPackage ../development/python-modules/datrie { };

  heapdict = callPackage ../development/python-modules/heapdict { };

  zict = callPackage ../development/python-modules/zict { };

  digital-ocean = callPackage ../development/python-modules/digitalocean { };

  leather = callPackage ../development/python-modules/leather { };

  libais = callPackage ../development/python-modules/libais { };

  libtmux = callPackage ../development/python-modules/libtmux { };

  libusb1 = callPackage ../development/python-modules/libusb1 { inherit (pkgs) libusb1; };

  linuxfd = callPackage ../development/python-modules/linuxfd { };

  locket = callPackage ../development/python-modules/locket { };

  tblib = callPackage ../development/python-modules/tblib { };

  s3fs = callPackage ../development/python-modules/s3fs { };

  datashape = callPackage ../development/python-modules/datashape { };

  requests-cache = callPackage ../development/python-modules/requests-cache { };

  requests-file = callPackage ../development/python-modules/requests-file { };

  requests-kerberos = callPackage ../development/python-modules/requests-kerberos { };

  requests-unixsocket = callPackage ../development/python-modules/requests-unixsocket {};

  requests-aws4auth = callPackage ../development/python-modules/requests-aws4auth { };

  howdoi = callPackage ../development/python-modules/howdoi {};

  neurotools = callPackage ../development/python-modules/neurotools {};

  jdatetime = callPackage ../development/python-modules/jdatetime {};

  daphne = callPackage ../development/python-modules/daphne { };

  dateparser = callPackage ../development/python-modules/dateparser { };

  # Actual name of package
  python-dateutil = callPackage ../development/python-modules/dateutil { };
  # Alias that we should deprecate
  dateutil = self.python-dateutil;

  decorator = callPackage ../development/python-modules/decorator { };

  deform = callPackage ../development/python-modules/deform { };

  demjson = callPackage ../development/python-modules/demjson { };

  deprecation = callPackage ../development/python-modules/deprecation { };

  derpconf = callPackage ../development/python-modules/derpconf { };

  deskcon = callPackage ../development/python-modules/deskcon { };

  dill = callPackage ../development/python-modules/dill { };

  discogs_client = callPackage ../development/python-modules/discogs_client { };

  dmenu-python = callPackage ../development/python-modules/dmenu { };

  dnspython = callPackage ../development/python-modules/dnspython { };
  dns = self.dnspython; # Alias for compatibility, 2017-12-10

  docker = callPackage ../development/python-modules/docker {};

  dockerpty = callPackage ../development/python-modules/dockerpty {};

  docker_pycreds = callPackage ../development/python-modules/docker-pycreds {};

  docopt = callPackage ../development/python-modules/docopt { };

  doctest-ignore-unicode = callPackage ../development/python-modules/doctest-ignore-unicode { };

  dogpile_cache = callPackage ../development/python-modules/dogpile.cache { };

  dogpile_core = callPackage ../development/python-modules/dogpile.core { };

  dopy = callPackage ../development/python-modules/dopy { };

  dpath = callPackage ../development/python-modules/dpath { };

  dpkt = callPackage ../development/python-modules/dpkt {};

  urllib3 = callPackage ../development/python-modules/urllib3 {};

  dropbox = callPackage ../development/python-modules/dropbox {};

  ds4drv = callPackage ../development/python-modules/ds4drv {
    inherit (pkgs) fetchFromGitHub bluez;
  };

  dyn = callPackage ../development/python-modules/dyn { };

  easydict = callPackage ../development/python-modules/easydict { };

  easygui = callPackage ../development/python-modules/easygui { };

  EasyProcess = callPackage ../development/python-modules/easyprocess { };

  easy-thumbnails = callPackage ../development/python-modules/easy-thumbnails { };

  eccodes = toPythonModule (pkgs.eccodes.override {
    enablePython = true;
    pythonPackages = self;
  });

  EditorConfig = callPackage ../development/python-modules/editorconfig { };

  edward = callPackage ../development/python-modules/edward { };

  elasticsearch = callPackage ../development/python-modules/elasticsearch { };

  elasticsearch-dsl = callPackage ../development/python-modules/elasticsearch-dsl { };
  # alias
  elasticsearchdsl = self.elasticsearch-dsl;

  elasticsearch-curator = callPackage ../development/python-modules/elasticsearch-curator { };

  entrypoints = callPackage ../development/python-modules/entrypoints { };

  enzyme = callPackage ../development/python-modules/enzyme {};

  escapism = callPackage ../development/python-modules/escapism { };

  etcd = callPackage ../development/python-modules/etcd { };

  evdev = callPackage ../development/python-modules/evdev {};

  eve = callPackage ../development/python-modules/eve {};

  eventlib = callPackage ../development/python-modules/eventlib { };

  events = callPackage ../development/python-modules/events { };

  eyeD3 = callPackage ../development/python-modules/eyed3 { };

  execnet = callPackage ../development/python-modules/execnet { };

  ezdxf = callPackage ../development/python-modules/ezdxf {};

  facebook-sdk = callPackage ../development/python-modules/facebook-sdk { };

  face_recognition = callPackage ../development/python-modules/face_recognition { };

  face_recognition_models = callPackage ../development/python-modules/face_recognition_models { };

  faker = callPackage ../development/python-modules/faker { };

  fake_factory = callPackage ../development/python-modules/fake_factory { };

  factory_boy = callPackage ../development/python-modules/factory_boy { };

  Fabric = callPackage ../development/python-modules/Fabric { };

  faulthandler = if ! isPy3k
    then callPackage ../development/python-modules/faulthandler {}
    else throw "faulthandler is built into ${python.executable}";

  fb-re2 = callPackage ../development/python-modules/fb-re2 { };

  flexmock = callPackage ../development/python-modules/flexmock { };

  flit = callPackage ../development/python-modules/flit { };

  flowlogs_reader = callPackage ../development/python-modules/flowlogs_reader { };

  fluent-logger = callPackage ../development/python-modules/fluent-logger {};

  python-forecastio = callPackage ../development/python-modules/python-forecastio { };

  fpdf = callPackage ../development/python-modules/fpdf { };

  fpylll = callPackage ../development/python-modules/fpylll { };

  fritzconnection = callPackage ../development/python-modules/fritzconnection { };

  frozendict = callPackage ../development/python-modules/frozendict { };

  ftputil = callPackage ../development/python-modules/ftputil { };

  fudge = callPackage ../development/python-modules/fudge { };

  fudge_9 = self.fudge.overridePythonAttrs (old: rec {
     version = "0.9.6";

     src = fetchPypi {
      pname = "fudge";
      inherit version;
      sha256 = "34690c4692e8717f4d6a2ab7d841070c93c8d0ea0d2615b47064e291f750b1a0";
    };
  });

  funcparserlib = callPackage ../development/python-modules/funcparserlib { };

  fastcache = callPackage ../development/python-modules/fastcache { };

  functools32 = callPackage ../development/python-modules/functools32 { };

  gateone = callPackage ../development/python-modules/gateone { };

  # TODO: Remove after 19.03 is branched off:
  gcutil = throw ''
    pythonPackages.gcutil is deprecated and can be replaced with "gcloud
    compute" from the package google-cloud-sdk.
  '';

  GeoIP = callPackage ../development/python-modules/GeoIP { };

  gmpy = callPackage ../development/python-modules/gmpy { };

  gmpy2 = callPackage ../development/python-modules/gmpy2 { };

  gmusicapi = callPackage ../development/python-modules/gmusicapi { };

  gnureadline = callPackage ../development/python-modules/gnureadline { };

  gnutls = callPackage ../development/python-modules/gnutls { };

  gpy = callPackage ../development/python-modules/gpy { };

  gitdb = callPackage ../development/python-modules/gitdb { };

  gitdb2 = callPackage ../development/python-modules/gitdb2 { };

  GitPython = callPackage ../development/python-modules/GitPython { };

  git-annex-adapter = callPackage ../development/python-modules/git-annex-adapter {
    inherit (pkgs.gitAndTools) git-annex;
  };

  python-gitlab = callPackage ../development/python-modules/python-gitlab { };

  google-cloud-sdk = callPackage ../tools/admin/google-cloud-sdk { };
  google-cloud-sdk-gce = callPackage ../tools/admin/google-cloud-sdk { with-gce=true; };

  google-compute-engine = callPackage ../tools/virtualization/google-compute-engine { };

  gpapi = callPackage ../development/python-modules/gpapi { };
  gplaycli = callPackage ../development/python-modules/gplaycli { };

  gpsoauth = callPackage ../development/python-modules/gpsoauth { };

  grip = callPackage ../development/python-modules/grip { };

  gst-python = callPackage ../development/python-modules/gst-python {
    gst-plugins-base = pkgs.gst_all_1.gst-plugins-base;
  };

  gtimelog = callPackage ../development/python-modules/gtimelog { };

  gurobipy = if stdenv.hostPlatform.system == "x86_64-darwin"
  then callPackage ../development/python-modules/gurobipy/darwin.nix {
    inherit (pkgs.darwin) cctools insert_dylib;
  }
  else if stdenv.hostPlatform.system == "x86_64-linux"
  then callPackage ../development/python-modules/gurobipy/linux.nix {}
  else throw "gurobipy not yet supported on ${stdenv.hostPlatform.system}";

  hbmqtt = callPackage ../development/python-modules/hbmqtt { };

  hiro = callPackage ../development/python-modules/hiro {};

  hglib = callPackage ../development/python-modules/hglib {};

  humanize = callPackage ../development/python-modules/humanize { };

  hupper = callPackage ../development/python-modules/hupper {};

  hsaudiotag = callPackage ../development/python-modules/hsaudiotag { };

  hsaudiotag3k = callPackage ../development/python-modules/hsaudiotag3k { };

  htmlmin = callPackage ../development/python-modules/htmlmin {};

  httpauth = callPackage ../development/python-modules/httpauth { };

  idna-ssl = callPackage ../development/python-modules/idna-ssl { };

  identify = callPackage ../development/python-modules/identify { };

  ijson = callPackage ../development/python-modules/ijson {};

  imagesize = callPackage ../development/python-modules/imagesize { };

  image-match = callPackage ../development/python-modules/image-match { };

  imbalanced-learn = callPackage ../development/python-modules/imbalanced-learn { };

  immutables = callPackage ../development/python-modules/immutables {};

  imread = callPackage ../development/python-modules/imread { };

  imaplib2 = callPackage ../development/python-modules/imaplib2 { };

  ipfsapi = callPackage ../development/python-modules/ipfsapi { };

  itsdangerous = callPackage ../development/python-modules/itsdangerous { };

  iniparse = callPackage ../development/python-modules/iniparse { };

  i3-py = callPackage ../development/python-modules/i3-py { };

  JayDeBeApi = callPackage ../development/python-modules/JayDeBeApi {};

  jdcal = callPackage ../development/python-modules/jdcal { };

  jieba = callPackage ../development/python-modules/jieba { };

  internetarchive = callPackage ../development/python-modules/internetarchive {};

  JPype1 = callPackage ../development/python-modules/JPype1 {};

  josepy = callPackage ../development/python-modules/josepy {};

  jsbeautifier = callPackage ../development/python-modules/jsbeautifier {};

  jug = callPackage ../development/python-modules/jug {};

  jsmin = callPackage ../development/python-modules/jsmin { };

  jsonpatch = callPackage ../development/python-modules/jsonpatch { };

  jsonpickle = callPackage ../development/python-modules/jsonpickle { };

  jsonpointer = callPackage ../development/python-modules/jsonpointer { };

  jsonrpclib = callPackage ../development/python-modules/jsonrpclib { };

  jsonrpclib-pelix = callPackage ../development/python-modules/jsonrpclib-pelix {};

  jsonwatch = callPackage ../development/python-modules/jsonwatch { };

  latexcodec = callPackage ../development/python-modules/latexcodec {};

  libsexy = callPackage ../development/python-modules/libsexy {
    libsexy = pkgs.libsexy;
  };

  libsoundtouch = callPackage ../development/python-modules/libsoundtouch { };

  libthumbor = callPackage ../development/python-modules/libthumbor { };

  lightblue = callPackage ../development/python-modules/lightblue { };

  lightning = callPackage ../development/python-modules/lightning { };

  jupyter = callPackage ../development/python-modules/jupyter { };

  jupyter_console = if pythonOlder "3.5" then
       callPackage ../development/python-modules/jupyter_console/5.nix { }
     else
       callPackage ../development/python-modules/jupyter_console { };

  jupyterlab_launcher = callPackage ../development/python-modules/jupyterlab_launcher { };

  jupyterlab_server = callPackage ../development/python-modules/jupyterlab_server { };

  jupyterlab = callPackage ../development/python-modules/jupyterlab {};

  jupytext = callPackage ../development/python-modules/jupytext { };

  PyLTI = callPackage ../development/python-modules/pylti { };

  lmdb = callPackage ../development/python-modules/lmdb { };

  logilab_astng = callPackage ../development/python-modules/logilab_astng { };

  lpod = callPackage ../development/python-modules/lpod { };

  ludios_wpull = callPackage ../development/python-modules/ludios_wpull { };

  luftdaten = callPackage ../development/python-modules/luftdaten { };

  m2r = callPackage ../development/python-modules/m2r { };

  mailchimp = callPackage ../development/python-modules/mailchimp { };

  python-mapnik = callPackage ../development/python-modules/python-mapnik { };

  misaka = callPackage ../development/python-modules/misaka {};

  mt-940 = callPackage ../development/python-modules/mt-940 { };

  mwlib = callPackage ../development/python-modules/mwlib { };

  mwlib-ext = callPackage ../development/python-modules/mwlib-ext { };

  mwlib-rl = callPackage ../development/python-modules/mwlib-rl { };

  natsort = callPackage ../development/python-modules/natsort { };

  ncclient = callPackage ../development/python-modules/ncclient {};

  logfury = callPackage ../development/python-modules/logfury { };

  ndg-httpsclient = callPackage ../development/python-modules/ndg-httpsclient { };

  netcdf4 = callPackage ../development/python-modules/netcdf4 { };

  netdisco = callPackage ../development/python-modules/netdisco { };

  Nikola = callPackage ../development/python-modules/Nikola { };

  nxt-python = callPackage ../development/python-modules/nxt-python { };

  odfpy = callPackage ../development/python-modules/odfpy { };

  oset = callPackage ../development/python-modules/oset { };

  pamela = callPackage ../development/python-modules/pamela { };

  # These used to be here but were moved to all-packages, but I'll leave them around for a while.
  pants = pkgs.pants;

  paperspace = callPackage ../development/python-modules/paperspace { };

  paperwork-backend = callPackage ../applications/office/paperwork/backend.nix { };

  papis-python-rofi = callPackage ../development/python-modules/papis-python-rofi { };

  pathspec = callPackage ../development/python-modules/pathspec { };

  pathtools = callPackage ../development/python-modules/pathtools { };

  paver = callPackage ../development/python-modules/paver { };

  passlib = callPackage ../development/python-modules/passlib { };

  path-and-address = callPackage ../development/python-modules/path-and-address { };

  peppercorn = callPackage ../development/python-modules/peppercorn { };

  pex = callPackage ../development/python-modules/pex { };

  phe = callPackage ../development/python-modules/phe { };

  phpserialize = callPackage ../development/python-modules/phpserialize { };

  plaid-python = callPackage ../development/python-modules/plaid-python { };

  plaster = callPackage ../development/python-modules/plaster {};

  plaster-pastedeploy = callPackage ../development/python-modules/plaster-pastedeploy {};

  plotly = callPackage ../development/python-modules/plotly { };

  plyfile = callPackage ../development/python-modules/plyfile { };

  podcastparser = callPackage ../development/python-modules/podcastparser { };

  podcats = callPackage ../development/python-modules/podcats { };

  pomegranate = callPackage ../development/python-modules/pomegranate { };

  poppler-qt5 = callPackage ../development/python-modules/poppler-qt5 {
    inherit (pkgs.qt5) qtbase;
    inherit (pkgs.libsForQt5) poppler;
  };

  poyo = callPackage ../development/python-modules/poyo { };

  priority = callPackage ../development/python-modules/priority { };

  prov = callPackage ../development/python-modules/prov { };

  pudb = callPackage ../development/python-modules/pudb { };

  pybtex = callPackage ../development/python-modules/pybtex {};

  pybtex-docutils = callPackage ../development/python-modules/pybtex-docutils {};

  pycallgraph = callPackage ../development/python-modules/pycallgraph { };

  pycassa = callPackage ../development/python-modules/pycassa { };

  lirc = disabledIf isPy27 (toPythonModule (pkgs.lirc.override {
    python3 = python;
  }));

  pyblake2 = callPackage ../development/python-modules/pyblake2 { };

  pybluez = callPackage ../development/python-modules/pybluez { };

  pycares = callPackage ../development/python-modules/pycares { };

  pycuda = callPackage ../development/python-modules/pycuda rec {
    cudatoolkit = pkgs.cudatoolkit_7_5;
    inherit (pkgs.stdenv) mkDerivation;
  };

  pydotplus = callPackage ../development/python-modules/pydotplus { };

  pyfxa = callPackage ../development/python-modules/pyfxa { };

  pyhomematic = callPackage ../development/python-modules/pyhomematic { };

  pylama = callPackage ../development/python-modules/pylama { };

  pymediainfo = callPackage ../development/python-modules/pymediainfo { };

  pyphen = callPackage ../development/python-modules/pyphen {};

  pypoppler = callPackage ../development/python-modules/pypoppler { };

  pypillowfight = callPackage ../development/python-modules/pypillowfight { };

  pyprind = callPackage ../development/python-modules/pyprind { };

  python-axolotl = callPackage ../development/python-modules/python-axolotl { };

  python-axolotl-curve25519 = callPackage ../development/python-modules/python-axolotl-curve25519 { };

  pythonix = toPythonModule (callPackage ../development/python-modules/pythonix { });

  pyramid = callPackage ../development/python-modules/pyramid { };

  pyramid_beaker = callPackage ../development/python-modules/pyramid_beaker { };

  pyramid_chameleon = callPackage ../development/python-modules/pyramid_chameleon { };

  pyramid_jinja2 = callPackage ../development/python-modules/pyramid_jinja2 { };

  pyramid_mako = callPackage ../development/python-modules/pyramid_mako { };

  peewee =  callPackage ../development/python-modules/peewee { };

  pyroute2 = callPackage ../development/python-modules/pyroute2 { };

  pyspf = callPackage ../development/python-modules/pyspf { };

  pysrim = callPackage ../development/python-modules/pysrim { };

  pysrt = callPackage ../development/python-modules/pysrt { };

  pytools = callPackage ../development/python-modules/pytools { };

  python-ctags3 = callPackage ../development/python-modules/python-ctags3 { };

  junos-eznc = callPackage ../development/python-modules/junos-eznc {};

  raven = callPackage ../development/python-modules/raven { };

  rawkit = callPackage ../development/python-modules/rawkit { };

  joblib = callPackage ../development/python-modules/joblib { };

  sarge = callPackage ../development/python-modules/sarge { };

  subliminal = callPackage ../development/python-modules/subliminal {};

  hyperlink = callPackage ../development/python-modules/hyperlink {};

  zope_copy = callPackage ../development/python-modules/zope_copy {};

  s2clientprotocol = callPackage ../development/python-modules/s2clientprotocol { };

  py3status = callPackage ../development/python-modules/py3status {};

  pyrtlsdr = callPackage ../development/python-modules/pyrtlsdr { };

  scandir = callPackage ../development/python-modules/scandir { };

  schema = callPackage ../development/python-modules/schema {};

  simple-websocket-server = callPackage ../development/python-modules/simple-websocket-server {};

  stem = callPackage ../development/python-modules/stem { };

  svg-path = callPackage ../development/python-modules/svg-path { };

  r2pipe = callPackage ../development/python-modules/r2pipe { };

  regex = callPackage ../development/python-modules/regex { };

  ratelimiter = callPackage ../development/python-modules/ratelimiter { };

  pywatchman = callPackage ../development/python-modules/pywatchman { };

  pywavelets = callPackage ../development/python-modules/pywavelets { };

  vcrpy = callPackage ../development/python-modules/vcrpy { };

  descartes = callPackage ../development/python-modules/descartes { };

  chardet = callPackage ../development/python-modules/chardet { };

  pyramid_exclog = callPackage ../development/python-modules/pyramid_exclog { };

  pyramid_multiauth = callPackage ../development/python-modules/pyramid_multiauth { };

  pyramid_hawkauth = callPackage ../development/python-modules/pyramid_hawkauth { };

  pytun = callPackage ../development/python-modules/pytun { };

  rethinkdb = callPackage ../development/python-modules/rethinkdb { };

  roman = callPackage ../development/python-modules/roman { };

  librosa = callPackage ../development/python-modules/librosa { };

  samplerate = callPackage ../development/python-modules/samplerate { };

  ssdeep = callPackage ../development/python-modules/ssdeep { };

  statsd = callPackage ../development/python-modules/statsd { };

  multi_key_dict = callPackage ../development/python-modules/multi_key_dict { };

  random2 = callPackage ../development/python-modules/random2 { };

  schedule = callPackage ../development/python-modules/schedule { };

  repoze_lru = callPackage ../development/python-modules/repoze_lru { };

  repoze_sphinx_autointerface =  callPackage ../development/python-modules/repoze_sphinx_autointerface { };

  setuptools-git = callPackage ../development/python-modules/setuptools-git { };

  sievelib = callPackage ../development/python-modules/sievelib { };

  watchdog = callPackage ../development/python-modules/watchdog { };

  zope_deprecation = callPackage ../development/python-modules/zope_deprecation { };

  validictory = callPackage ../development/python-modules/validictory { };

  venusian = callPackage ../development/python-modules/venusian { };

  chameleon = callPackage ../development/python-modules/chameleon { };

  ddt = callPackage ../development/python-modules/ddt { };

  distutils_extra = callPackage ../development/python-modules/distutils_extra { };

  pyxdg = callPackage ../development/python-modules/pyxdg { };

  crayons = callPackage ../development/python-modules/crayons{ };

  django = self.django_1_11;

  django_1_11 = callPackage ../development/python-modules/django/1_11.nix {
    gdal = self.gdal;
  };

  django_2_0 = callPackage ../development/python-modules/django/2_0.nix {
    gdal = self.gdal;
  };

  django_2_1 = callPackage ../development/python-modules/django/2_1.nix {
    gdal = self.gdal;
  };

  django_1_8 = callPackage ../development/python-modules/django/1_8.nix { };

  django-allauth = callPackage ../development/python-modules/django-allauth { };

  django_appconf = callPackage ../development/python-modules/django_appconf { };

  django_colorful = callPackage ../development/python-modules/django_colorful { };

  django-cache-url = callPackage ../development/python-modules/django-cache-url { };

  django-configurations = callPackage ../development/python-modules/django-configurations { };

  django_compressor = callPackage ../development/python-modules/django_compressor { };

  django_compat = callPackage ../development/python-modules/django-compat { };

  django_contrib_comments = callPackage ../development/python-modules/django_contrib_comments { };

  django-discover-runner = callPackage ../development/python-modules/django-discover-runner { };

  django_environ = callPackage ../development/python-modules/django_environ { };

  django_evolution = callPackage ../development/python-modules/django_evolution { };

  django_extensions = callPackage ../development/python-modules/django-extensions { };

  django-gravatar2 = callPackage ../development/python-modules/django-gravatar2 { };

  django_guardian = callPackage ../development/python-modules/django_guardian { };

  django-ipware = callPackage ../development/python-modules/django-ipware { };

  django-jinja = callPackage ../development/python-modules/django-jinja2 { };

  django-pglocks = callPackage ../development/python-modules/django-pglocks { };

  django-picklefield = callPackage ../development/python-modules/django-picklefield { };

  django_polymorphic = callPackage ../development/python-modules/django-polymorphic { };

  django-sampledatahelper = callPackage ../development/python-modules/django-sampledatahelper { };

  django-sites = callPackage ../development/python-modules/django-sites { };

  django-sr = callPackage ../development/python-modules/django-sr { };

  django_tagging = callPackage ../development/python-modules/django_tagging { };

  django_tagging_0_4_3 = if
       self.django.version != "1.8.19"
  then throw "django_tagging_0_4_3 should be build with django_1_8"
  else (callPackage ../development/python-modules/django_tagging {}).overrideAttrs (attrs: rec {
    pname = "django-tagging";
    version = "0.4.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0617azpmp6jpg3d88v2ir97qrc9aqcs2s9gyvv9bgf2cp55khxhs";
    };
    propagatedBuildInputs = with self; [ django ];
  });

  django_classytags = callPackage ../development/python-modules/django_classytags { };

  # This package may need an older version of Django.
  # Override the package set and set e.g. `django = super.django_1_9`.
  # See the Nixpkgs manual for examples on how to override the package set.
  django_hijack = callPackage ../development/python-modules/django-hijack { };

  django_hijack_admin = callPackage ../development/python-modules/django-hijack-admin { };

  django_nose = callPackage ../development/python-modules/django_nose { };

  django_modelcluster = callPackage ../development/python-modules/django_modelcluster { };

  djangorestframework = callPackage ../development/python-modules/djangorestframework { };

  django-raster = callPackage ../development/python-modules/django-raster { };

  django_redis = callPackage ../development/python-modules/django_redis { };

  django_reversion = callPackage ../development/python-modules/django_reversion { };

  django_silk = callPackage ../development/python-modules/django_silk { };

  django_taggit = callPackage ../development/python-modules/django_taggit { };

  django_treebeard = callPackage ../development/python-modules/django_treebeard { };

  django_pipeline = callPackage ../development/python-modules/django-pipeline { };

  dj-database-url = callPackage ../development/python-modules/dj-database-url { };

  dj-email-url = callPackage ../development/python-modules/dj-email-url { };

  dj-search-url = callPackage ../development/python-modules/dj-search-url { };

  djmail = callPackage ../development/python-modules/djmail { };

  pillowfight = callPackage ../development/python-modules/pillowfight { };

  kaptan = callPackage ../development/python-modules/kaptan { };

  keepalive = callPackage ../development/python-modules/keepalive { };

  keyrings-alt = callPackage ../development/python-modules/keyrings-alt {};

  SPARQLWrapper = callPackage ../development/python-modules/sparqlwrapper { };

  dulwich = callPackage ../development/python-modules/dulwich {
    inherit (pkgs) git glibcLocales;
  };

  hg-git = callPackage ../development/python-modules/hg-git { };

  dtopt = callPackage ../development/python-modules/dtopt { };

  easywatch = callPackage ../development/python-modules/easywatch { };

  ecdsa = callPackage ../development/python-modules/ecdsa { };

  effect = callPackage ../development/python-modules/effect {};

  elpy = callPackage ../development/python-modules/elpy { };

  enum = callPackage ../development/python-modules/enum { };

  enum-compat = callPackage ../development/python-modules/enum-compat { };

  enum34 = callPackage ../development/python-modules/enum34 { };

  epc = callPackage ../development/python-modules/epc { };

  et_xmlfile = callPackage ../development/python-modules/et_xmlfile { };

  eventlet = callPackage ../development/python-modules/eventlet { };

  exifread = callPackage ../development/python-modules/exifread { };

  fastimport = callPackage ../development/python-modules/fastimport { };

  fastpair = callPackage ../development/python-modules/fastpair { };

  fastrlock = callPackage ../development/python-modules/fastrlock {};

  feedgen = callPackage ../development/python-modules/feedgen { };

  feedgenerator = callPackage ../development/python-modules/feedgenerator {
    inherit (pkgs) glibcLocales;
  };

  feedparser = callPackage ../development/python-modules/feedparser { };

  pyfribidi = callPackage ../development/python-modules/pyfribidi { };

  pyftpdlib = callPackage ../development/python-modules/pyftpdlib { };

  fdroidserver = callPackage ../development/python-modules/fdroidserver { };

  filebrowser_safe = callPackage ../development/python-modules/filebrowser_safe { };

  pycodestyle = callPackage ../development/python-modules/pycodestyle { };

  filebytes = callPackage ../development/python-modules/filebytes { };

  filelock = callPackage ../development/python-modules/filelock {};

  fiona = callPackage ../development/python-modules/fiona { gdal = pkgs.gdal; };

  flake8 = callPackage ../development/python-modules/flake8 { };

  flake8-blind-except = callPackage ../development/python-modules/flake8-blind-except { };

  flake8-debugger = callPackage ../development/python-modules/flake8-debugger { };

  flake8-future-import = callPackage ../development/python-modules/flake8-future-import { };

  flake8-import-order = callPackage ../development/python-modules/flake8-import-order { };

  flaky = callPackage ../development/python-modules/flaky { };

  flask = callPackage ../development/python-modules/flask { };

  flask-api = callPackage ../development/python-modules/flask-api { };

  flask_assets = callPackage ../development/python-modules/flask-assets { };

  flask-autoindex = callPackage ../development/python-modules/flask-autoindex { };

  flask-babel = callPackage ../development/python-modules/flask-babel { };

  flask-bootstrap = callPackage ../development/python-modules/flask-bootstrap { };

  flask-caching = callPackage ../development/python-modules/flask-caching { };

  flask-common = callPackage ../development/python-modules/flask-common { };

  flask-compress = callPackage ../development/python-modules/flask-compress { };

  flask-cors = callPackage ../development/python-modules/flask-cors { };

  flask_elastic = callPackage ../development/python-modules/flask-elastic { };

  flask-jwt-extended = callPackage ../development/python-modules/flask-jwt-extended { };

  flask-limiter = callPackage ../development/python-modules/flask-limiter { };

  flask_login = callPackage ../development/python-modules/flask-login { };

  flask_ldap_login = callPackage ../development/python-modules/flask-ldap-login { };

  flask_mail = callPackage ../development/python-modules/flask-mail { };

  flask_marshmallow = callPackage ../development/python-modules/flask-marshmallow { };

  flask_migrate = callPackage ../development/python-modules/flask-migrate { };

  flask_oauthlib = callPackage ../development/python-modules/flask-oauthlib { };

  flask-paginate = callPackage ../development/python-modules/flask-paginate { };

  flask_principal = callPackage ../development/python-modules/flask-principal { };

  flask-pymongo = callPackage ../development/python-modules/Flask-PyMongo { };

  flask-restful = callPackage ../development/python-modules/flask-restful { };

  flask-restplus = callPackage ../development/python-modules/flask-restplus { };

  flask_script = callPackage ../development/python-modules/flask-script { };

  flask-silk = callPackage ../development/python-modules/flask-silk { };

  flask-socketio = callPackage ../development/python-modules/flask-socketio { };

  flask_sqlalchemy = callPackage ../development/python-modules/flask-sqlalchemy { };

  flask_testing = callPackage ../development/python-modules/flask-testing { };

  flask_wtf = callPackage ../development/python-modules/flask-wtf { };

  wtforms = callPackage ../development/python-modules/wtforms { };

  graph-tool = callPackage ../development/python-modules/graph-tool/2.x.x.nix { };

  grappelli_safe = callPackage ../development/python-modules/grappelli_safe { };

  pytorch = callPackage ../development/python-modules/pytorch {
    cudaSupport = pkgs.config.cudaSupport or false;
  };

  pyro-ppl = callPackage ../development/python-modules/pyro-ppl {};

  opt-einsum = callPackage ../development/python-modules/opt-einsum {};

  pytorchWithCuda = self.pytorch.override {
    cudaSupport = true;
  };

  pytorchWithoutCuda = self.pytorch.override {
    cudaSupport = false;
  };

  python2-pythondialog = callPackage ../development/python-modules/python2-pythondialog { };

  pyRFC3339 = callPackage ../development/python-modules/pyrfc3339 { };

  ConfigArgParse = callPackage ../development/python-modules/configargparse { };

  jsonschema = callPackage ../development/python-modules/jsonschema { };

  vcversioner = callPackage ../development/python-modules/vcversioner { };

  falcon = callPackage ../development/python-modules/falcon { };

  hug = callPackage ../development/python-modules/hug { };

  flup = callPackage ../development/python-modules/flup { };

  fn = callPackage ../development/python-modules/fn { };

  folium = callPackage ../development/python-modules/folium { };

  fontforge = toPythonModule (pkgs.fontforge.override {
    withPython = true;
    inherit python;
  });

  fonttools = callPackage ../development/python-modules/fonttools { };

  foolscap = callPackage ../development/python-modules/foolscap { };

  forbiddenfruit = callPackage ../development/python-modules/forbiddenfruit { };

  fusepy = callPackage ../development/python-modules/fusepy { };

  future = callPackage ../development/python-modules/future { };
  future15 = self.future.overridePythonAttrs (old: rec {
    name = "future-${version}";
    version = "0.15.2";
    src = fetchPypi {
      pname = "future";
      version = "0.15.2";
      sha256 = "15wvcfzssc68xqnqi1dq4fhd0848hwi9jn42hxyvlqna40zijfrx";
    };
  });

  futures = callPackage ../development/python-modules/futures { };

  gcovr = callPackage ../development/python-modules/gcovr { };

  gdal = toPythonModule (pkgs.gdal.override {
    pythonPackages = self;
  });

  gdrivefs = callPackage ../development/python-modules/gdrivefs { };

  genshi = callPackage ../development/python-modules/genshi { };

  gentools = callPackage ../development/python-modules/gentools { };

  gevent = callPackage ../development/python-modules/gevent { };

  geventhttpclient = callPackage ../development/python-modules/geventhttpclient { };

  gevent-socketio = callPackage ../development/python-modules/gevent-socketio { };

  geopandas = callPackage ../development/python-modules/geopandas { };

  geojson = callPackage ../development/python-modules/geojson { };

  gevent-websocket = callPackage ../development/python-modules/gevent-websocket { };

  genzshcomp = callPackage ../development/python-modules/genzshcomp { };

  gflags = callPackage ../development/python-modules/gflags { };

  ghdiff = callPackage ../development/python-modules/ghdiff { };

  gipc = callPackage ../development/python-modules/gipc { };

  git-sweep = callPackage ../development/python-modules/git-sweep { };

  glances = callPackage ../development/python-modules/glances { };

  github3_py = callPackage ../development/python-modules/github3_py { };

  github-webhook = callPackage ../development/python-modules/github-webhook { };

  goobook = callPackage ../development/python-modules/goobook { };

  googleapis_common_protos = callPackage ../development/python-modules/googleapis_common_protos { };

  google-auth-httplib2 = callPackage ../development/python-modules/google-auth-httplib2 { };

  google_api_core = callPackage ../development/python-modules/google_api_core { };

  google_api_python_client = callPackage ../development/python-modules/google-api-python-client { };

  google_apputils = callPackage ../development/python-modules/google_apputils { };

  google_auth = callPackage ../development/python-modules/google_auth { };

  google_cloud_asset = callPackage ../development/python-modules/google_cloud_asset { };

  google_cloud_automl = callPackage ../development/python-modules/google_cloud_automl { };

  google_cloud_core = callPackage ../development/python-modules/google_cloud_core { };

  google_cloud_bigquery = callPackage ../development/python-modules/google_cloud_bigquery { };

  google_cloud_bigquery_datatransfer = callPackage ../development/python-modules/google_cloud_bigquery_datatransfer { };

  google_cloud_bigtable = callPackage ../development/python-modules/google_cloud_bigtable { };

  google_cloud_container = callPackage ../development/python-modules/google_cloud_container { };

  google_cloud_dataproc = callPackage ../development/python-modules/google_cloud_dataproc { };

  google_cloud_datastore = callPackage ../development/python-modules/google_cloud_datastore { };

  google_cloud_dlp = callPackage ../development/python-modules/google_cloud_dlp { };

  google_cloud_dns = callPackage ../development/python-modules/google_cloud_dns { };

  google_cloud_error_reporting = callPackage ../development/python-modules/google_cloud_error_reporting { };

  google_cloud_firestore = callPackage ../development/python-modules/google_cloud_firestore { };

  google_cloud_iot = callPackage ../development/python-modules/google_cloud_iot { };

  google_cloud_kms = callPackage ../development/python-modules/google_cloud_kms { };

  google_cloud_language = callPackage ../development/python-modules/google_cloud_language { };

  google_cloud_logging = callPackage ../development/python-modules/google_cloud_logging { };

  google_cloud_monitoring = callPackage ../development/python-modules/google_cloud_monitoring { };

  google_cloud_pubsub = callPackage ../development/python-modules/google_cloud_pubsub { };

  google_cloud_redis = callPackage ../development/python-modules/google_cloud_redis { };

  google_cloud_resource_manager = callPackage ../development/python-modules/google_cloud_resource_manager { };

  google_cloud_runtimeconfig = callPackage ../development/python-modules/google_cloud_runtimeconfig { };

  google_cloud_securitycenter = callPackage ../development/python-modules/google_cloud_securitycenter { };

  google_cloud_spanner = callPackage ../development/python-modules/google_cloud_spanner { };

  google_cloud_storage = callPackage ../development/python-modules/google_cloud_storage { };

  google_cloud_speech = callPackage ../development/python-modules/google_cloud_speech { };

  google_cloud_tasks = callPackage ../development/python-modules/google_cloud_tasks { };

  google_cloud_testutils = callPackage ../development/python-modules/google_cloud_testutils { };

  google_cloud_texttospeech = callPackage ../development/python-modules/google_cloud_texttospeech { };

  google_cloud_trace = callPackage ../development/python-modules/google_cloud_trace { };

  google_cloud_translate = callPackage ../development/python-modules/google_cloud_translate { };

  google_cloud_videointelligence = callPackage ../development/python-modules/google_cloud_videointelligence { };

  google_cloud_vision = callPackage ../development/python-modules/google_cloud_vision { };

  google_cloud_websecurityscanner = callPackage ../development/python-modules/google_cloud_websecurityscanner { };

  google-i18n-address = callPackage ../development/python-modules/google-i18n-address { };

  google_resumable_media = callPackage ../development/python-modules/google_resumable_media { };

  gpgme = toPythonModule (pkgs.gpgme.override {
    pythonSupport = true;
    inherit python;
  });

  gphoto2 = callPackage ../development/python-modules/gphoto2 {
    inherit (pkgs) pkgconfig;
  };

  grammalecte = callPackage ../development/python-modules/grammalecte { };

  greenlet = callPackage ../development/python-modules/greenlet { };

  grib-api = disabledIf (!isPy27) (toPythonModule
    (pkgs.grib-api.override {
      enablePython = true;
      pythonPackages = self;
    }));

  grpcio = callPackage ../development/python-modules/grpcio { };

  grpcio-tools = callPackage ../development/python-modules/grpcio-tools { };

  grpcio-gcp = callPackage ../development/python-modules/grpcio-gcp { };

  grpc_google_iam_v1 = callPackage ../development/python-modules/grpc_google_iam_v1 { };

  gspread = callPackage ../development/python-modules/gspread { };

  gym = callPackage ../development/python-modules/gym { };

  gyp = callPackage ../development/python-modules/gyp { };

  guessit = callPackage ../development/python-modules/guessit { };

  rebulk = callPackage ../development/python-modules/rebulk { };

  gunicorn = callPackage ../development/python-modules/gunicorn { };

  hawkauthlib = callPackage ../development/python-modules/hawkauthlib { };

  hdbscan = callPackage ../development/python-modules/hdbscan { };

  hmmlearn = callPackage ../development/python-modules/hmmlearn { };

  hcs_utils = callPackage ../development/python-modules/hcs_utils { };

  hetzner = callPackage ../development/python-modules/hetzner { };

  homeassistant-pyozw = callPackage ../development/python-modules/homeassistant-pyozw { };

  htmllaundry = callPackage ../development/python-modules/htmllaundry { };

  html5lib = callPackage ../development/python-modules/html5lib { };

  httmock = callPackage ../development/python-modules/httmock { };

  http_signature = callPackage ../development/python-modules/http_signature { };

  httpbin = callPackage ../development/python-modules/httpbin { };

  httplib2 = callPackage ../development/python-modules/httplib2 { };

  hvac = callPackage ../development/python-modules/hvac { };

  hypothesis = callPackage ../development/python-modules/hypothesis { };

  colored = callPackage ../development/python-modules/colored { };

  xdis = callPackage ../development/python-modules/xdis { };

  uncompyle6 = callPackage ../development/python-modules/uncompyle6 { };

  lsi = callPackage ../development/python-modules/lsi { };

  hkdf = callPackage ../development/python-modules/hkdf { };

  httpretty = callPackage ../development/python-modules/httpretty { };

  icalendar = callPackage ../development/python-modules/icalendar { };

  ifaddr = callPackage ../development/python-modules/ifaddr { };

  imageio = callPackage ../development/python-modules/imageio { };

  imgaug = callPackage ../development/python-modules/imgaug { };

  inflection = callPackage ../development/python-modules/inflection { };

  influxdb = callPackage ../development/python-modules/influxdb { };

  infoqscraper = callPackage ../development/python-modules/infoqscraper { };

  inifile = callPackage ../development/python-modules/inifile { };

  interruptingcow = callPackage ../development/python-modules/interruptingcow {};

  iocapture = callPackage ../development/python-modules/iocapture { };

  iptools = callPackage ../development/python-modules/iptools { };

  ipy = callPackage ../development/python-modules/IPy { };

  ipykernel = if pythonOlder "3.4" then
      callPackage ../development/python-modules/ipykernel/4.nix { }
    else
      callPackage ../development/python-modules/ipykernel { };

  ipyparallel = callPackage ../development/python-modules/ipyparallel { };

  ipython = if pythonOlder "3.5" then
      callPackage ../development/python-modules/ipython/5.nix { }
    else
      callPackage ../development/python-modules/ipython { };

  ipython_genutils = callPackage ../development/python-modules/ipython_genutils { };

  ipywidgets = callPackage ../development/python-modules/ipywidgets { };

  ipaddr = callPackage ../development/python-modules/ipaddr { };

  ipaddress = callPackage ../development/python-modules/ipaddress { };

  ipdb = callPackage ../development/python-modules/ipdb { };

  ipdbplugin = callPackage ../development/python-modules/ipdbplugin { };

  pythonIRClib = callPackage ../development/python-modules/pythonirclib { };

  iso-639 = callPackage ../development/python-modules/iso-639 {};

  iso3166 = callPackage ../development/python-modules/iso3166 {};

  iso8601 = callPackage ../development/python-modules/iso8601 { };

  isort = callPackage ../development/python-modules/isort {};

  jabberbot = callPackage ../development/python-modules/jabberbot {};

  jedi = callPackage ../development/python-modules/jedi { };

  jellyfish = callPackage ../development/python-modules/jellyfish { };

  jeepney = callPackage ../development/python-modules/jeepney { };

  j2cli = callPackage ../development/python-modules/j2cli { };

  jinja2 = callPackage ../development/python-modules/jinja2 { };

  jinja2_time = callPackage ../development/python-modules/jinja2_time { };

  jinja2_pluralize = callPackage ../development/python-modules/jinja2_pluralize { };

  jmespath = callPackage ../development/python-modules/jmespath { };

  journalwatch = callPackage ../tools/system/journalwatch {
    inherit (self) systemd pytest;
  };

  jsondate = callPackage ../development/python-modules/jsondate { };

  jsondiff = callPackage ../development/python-modules/jsondiff { };

  jsonnet = buildPythonPackage {
    inherit (pkgs.jsonnet) name src;
  };

  jupyter_client = callPackage ../development/python-modules/jupyter_client { };

  jupyter_core = callPackage ../development/python-modules/jupyter_core { };

  jupyter-repo2docker = callPackage ../development/python-modules/jupyter-repo2docker {
    pkgs-docker = pkgs.docker;
  };

  jupyterhub = callPackage ../development/python-modules/jupyterhub { };

  jupyterhub-ldapauthenticator = callPackage ../development/python-modules/jupyterhub-ldapauthenticator { };

  keyring = callPackage ../development/python-modules/keyring { };

  keyutils = callPackage ../development/python-modules/keyutils { inherit (pkgs) keyutils; };

  kiwisolver = callPackage ../development/python-modules/kiwisolver { };

  klaus = callPackage ../development/python-modules/klaus {};

  klein = callPackage ../development/python-modules/klein { };

  koji = callPackage ../development/python-modules/koji { };

  kombu = callPackage ../development/python-modules/kombu { };

  konfig = callPackage ../development/python-modules/konfig { };

  kitchen = callPackage ../development/python-modules/kitchen { };

  kubernetes = callPackage ../development/python-modules/kubernetes { };

  pylast = callPackage ../development/python-modules/pylast { };

  pylru = callPackage ../development/python-modules/pylru { };

  libnl-python = disabledIf isPy3k
    (toPythonModule (pkgs.libnl.override{pythonSupport=true; inherit python; })).py;

  lark-parser = callPackage ../development/python-modules/lark-parser { };

  jsonpath_rw = callPackage ../development/python-modules/jsonpath_rw { };

  kerberos = callPackage ../development/python-modules/kerberos { };

  lazy-object-proxy = callPackage ../development/python-modules/lazy-object-proxy { };

  ldaptor = callPackage ../development/python-modules/ldaptor { };

  le = callPackage ../development/python-modules/le { };

  lektor = callPackage ../development/python-modules/lektor { };

  python-oauth2 = callPackage ../development/python-modules/python-oauth2 { };

  python_openzwave = callPackage ../development/python-modules/python_openzwave { };

  python-Levenshtein = callPackage ../development/python-modules/python-levenshtein { };

  fs = callPackage ../development/python-modules/fs { };

  fs-s3fs = callPackage ../development/python-modules/fs-s3fs { };

  libarcus = callPackage ../development/python-modules/libarcus { };

  libcloud = callPackage ../development/python-modules/libcloud { };

  libgpuarray = callPackage ../development/python-modules/libgpuarray {
    clblas = pkgs.clblas.override { boost = self.boost; };
    cudaSupport = pkgs.config.cudaSupport or false;
    inherit (pkgs.linuxPackages) nvidia_x11;
  };

  libkeepass = callPackage ../development/python-modules/libkeepass { };

  librepo = toPythonModule (pkgs.librepo.override {
    inherit python;
  });

  libnacl = callPackage ../development/python-modules/libnacl {
    inherit (pkgs) libsodium;
  };

  libsavitar = callPackage ../development/python-modules/libsavitar { };

  libplist = disabledIf isPy3k
    (toPythonModule (pkgs.libplist.override{python2Packages=self; })).py;

  libxml2 = toPythonModule (pkgs.libxml2.override{pythonSupport=true; python2=python;}).py;

  libxslt = disabledIf isPy3k
    (toPythonModule (pkgs.libxslt.override{pythonSupport=true; python2=python; inherit (self) libxml2;})).py;

  limits = callPackage ../development/python-modules/limits { };

  limnoria = callPackage ../development/python-modules/limnoria { };

  line_profiler = callPackage ../development/python-modules/line_profiler { };

  linode = callPackage ../development/python-modules/linode { };

  linode-api = callPackage ../development/python-modules/linode-api { };

  livereload = callPackage ../development/python-modules/livereload { };

  llfuse = callPackage ../development/python-modules/llfuse {
    fuse = pkgs.fuse;  # use "real" fuse, not the python module
  };

  locustio = callPackage ../development/python-modules/locustio { };

  llvmlite = callPackage ../development/python-modules/llvmlite { llvm = pkgs.llvm_6; };

  lockfile = callPackage ../development/python-modules/lockfile { };

  logilab_common = callPackage ../development/python-modules/logilab/common.nix {};

  logilab-constraint = callPackage ../development/python-modules/logilab/constraint.nix {};

  lxml = callPackage ../development/python-modules/lxml {inherit (pkgs) libxml2 libxslt;};

  lxc = callPackage ../development/python-modules/lxc { };

  py_scrypt = callPackage ../development/python-modules/py_scrypt { };

  python_magic = callPackage ../development/python-modules/python-magic { };

  magic = callPackage ../development/python-modules/magic { };

  m2crypto = callPackage ../development/python-modules/m2crypto { };

  Mako = callPackage ../development/python-modules/Mako { };

  manifestparser = callPackage ../development/python-modules/marionette-harness/manifestparser.nix {};
  marionette_driver = callPackage ../development/python-modules/marionette-harness/marionette_driver.nix {};
  mozcrash = callPackage ../development/python-modules/marionette-harness/mozcrash.nix {};
  mozdevice = callPackage ../development/python-modules/marionette-harness/mozdevice.nix {};
  mozfile = callPackage ../development/python-modules/marionette-harness/mozfile.nix {};
  mozhttpd = callPackage ../development/python-modules/marionette-harness/mozhttpd.nix {};
  mozinfo = callPackage ../development/python-modules/marionette-harness/mozinfo.nix {};
  mozlog = callPackage ../development/python-modules/marionette-harness/mozlog.nix {};
  moznetwork = callPackage ../development/python-modules/marionette-harness/moznetwork.nix {};
  mozprocess = callPackage ../development/python-modules/marionette-harness/mozprocess.nix {};
  mozprofile = callPackage ../development/python-modules/marionette-harness/mozprofile.nix {};
  mozrunner = callPackage ../development/python-modules/marionette-harness/mozrunner.nix {};
  moztest = callPackage ../development/python-modules/marionette-harness/moztest.nix {};
  mozversion = callPackage ../development/python-modules/marionette-harness/mozversion.nix {};
  marionette-harness = callPackage ../development/python-modules/marionette-harness {};

  marisa = callPackage ../development/python-modules/marisa {
    marisa = pkgs.marisa;
  };

  marisa-trie = callPackage ../development/python-modules/marisa-trie { };

  markupsafe = callPackage ../development/python-modules/markupsafe { };

  marshmallow = callPackage ../development/python-modules/marshmallow { };

  marshmallow-sqlalchemy = callPackage ../development/python-modules/marshmallow-sqlalchemy { };

  manuel = callPackage ../development/python-modules/manuel { };

  mapsplotlib = callPackage ../development/python-modules/mapsplotlib { };

  markdown = callPackage ../development/python-modules/markdown { };

  markdownsuperscript = callPackage ../development/python-modules/markdownsuperscript {};

  markdown-macros = callPackage ../development/python-modules/markdown-macros { };

  mathics = callPackage ../development/python-modules/mathics { };

  matplotlib = let
    path = if isPy3k then ../development/python-modules/matplotlib/default.nix else
      ../development/python-modules/matplotlib/2.nix;
  in callPackage path {
    stdenv = if stdenv.isDarwin then pkgs.clangStdenv else pkgs.stdenv;
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
  };

  matrix-client = callPackage ../development/python-modules/matrix-client { };

  maya = callPackage ../development/python-modules/maya { };

  mccabe = callPackage ../development/python-modules/mccabe { };

  mechanize = callPackage ../development/python-modules/mechanize { };

  MechanicalSoup = callPackage ../development/python-modules/MechanicalSoup { };

  meld3 = callPackage ../development/python-modules/meld3 { };

  meliae = callPackage ../development/python-modules/meliae {};

  meinheld = callPackage ../development/python-modules/meinheld { };

  memcached = callPackage ../development/python-modules/memcached { };

  memory_profiler = callPackage ../development/python-modules/memory_profiler { };

  metaphone = callPackage ../development/python-modules/metaphone { };

  mezzanine = callPackage ../development/python-modules/mezzanine { };

  micawber = callPackage ../development/python-modules/micawber { };

  milksnake = callPackage ../development/python-modules/milksnake { };

  minimock = callPackage ../development/python-modules/minimock { };

  moviepy = callPackage ../development/python-modules/moviepy { };

  mozterm = callPackage ../development/python-modules/mozterm { };

  mplleaflet = callPackage ../development/python-modules/mplleaflet { };

  multidict = callPackage ../development/python-modules/multidict { };

  munch = callPackage ../development/python-modules/munch { };

  nototools = callPackage ../data/fonts/noto-fonts/tools.nix { };

  rainbowstream = callPackage ../development/python-modules/rainbowstream { };

  pendulum = callPackage ../development/python-modules/pendulum { };

  pocket = callPackage ../development/python-modules/pocket { };

  mistune = callPackage ../development/python-modules/mistune { };

  brotlipy = callPackage ../development/python-modules/brotlipy { };

  sortedcollections = callPackage ../development/python-modules/sortedcollections { };

  hyperframe = callPackage ../development/python-modules/hyperframe { };

  h2 = callPackage ../development/python-modules/h2 { };

  editorconfig = callPackage ../development/python-modules/editorconfig { };

  mock = callPackage ../development/python-modules/mock { };

  mock-open = callPackage ../development/python-modules/mock-open { };

  mockito = callPackage ../development/python-modules/mockito { };

  modestmaps = callPackage ../development/python-modules/modestmaps { };

  # Needed here because moinmoin is loaded as a Python library.
  moinmoin = callPackage ../development/python-modules/moinmoin { };

  moretools = callPackage ../development/python-modules/moretools { };

  moto = callPackage ../development/python-modules/moto {};

  mox = callPackage ../development/python-modules/mox { };

  mozsvc = callPackage ../development/python-modules/mozsvc { };

  mpmath = callPackage ../development/python-modules/mpmath { };

  mpd = callPackage ../development/python-modules/mpd { };

  mpd2 = callPackage ../development/python-modules/mpd2 { };

  mpv = callPackage ../development/python-modules/mpv { };

  mrbob = callPackage ../development/python-modules/mrbob {};

  msgpack = callPackage ../development/python-modules/msgpack {};

  msgpack-numpy = callPackage ../development/python-modules/msgpack-numpy {};

  msgpack-python = self.msgpack.overridePythonAttrs {
    pname = "msgpack-python";
    postPatch = ''
      substituteInPlace setup.py --replace "TRANSITIONAL = False" "TRANSITIONAL = True"
    '';
  };

  msrplib = callPackage ../development/python-modules/msrplib { };

  multipledispatch = callPackage ../development/python-modules/multipledispatch { };

  multiprocess = callPackage ../development/python-modules/multiprocess { };

  munkres = callPackage ../development/python-modules/munkres { };

  musicbrainzngs = callPackage ../development/python-modules/musicbrainzngs { };

  mutag = callPackage ../development/python-modules/mutag { };

  mutagen = callPackage ../development/python-modules/mutagen { };

  muttils = callPackage ../development/python-modules/muttils { };

  mygpoclient = callPackage ../development/python-modules/mygpoclient { };

  mysqlclient = callPackage ../development/python-modules/mysqlclient { };

  mypy = callPackage ../development/python-modules/mypy { };

  mypy_extensions = callPackage ../development/python-modules/mypy/extensions.nix { };

  mypy-protobuf = callPackage ../development/python-modules/mypy-protobuf { };

  neuronpy = callPackage ../development/python-modules/neuronpy { };

  pint = callPackage ../development/python-modules/pint { };

  pygal = callPackage ../development/python-modules/pygal { };

  pytaglib = callPackage ../development/python-modules/pytaglib { };

  pyte = callPackage ../development/python-modules/pyte { };

  graphviz = callPackage ../development/python-modules/graphviz {
    inherit (pkgs) graphviz;
  };

  pygraphviz = callPackage ../development/python-modules/pygraphviz {
    graphviz = pkgs.graphviz; # not the python package
  };

  pymc3 = callPackage ../development/python-modules/pymc3 { };

  pympler = callPackage ../development/python-modules/pympler { };

  pymysqlsa = callPackage ../development/python-modules/pymysqlsa { };

  monosat = disabledIf (!isPy3k) (pkgs.monosat.python { inherit buildPythonPackage; inherit (self) cython; });

  monotonic = callPackage ../development/python-modules/monotonic { };

  MySQL_python = callPackage ../development/python-modules/mysql_python { };

  mysql-connector = callPackage ../development/python-modules/mysql-connector { };

  namebench = callPackage ../development/python-modules/namebench { };

  namedlist = callPackage ../development/python-modules/namedlist { };

  nameparser = callPackage ../development/python-modules/nameparser { };

  nbconvert = callPackage ../development/python-modules/nbconvert { };

  nbformat = callPackage ../development/python-modules/nbformat { };

  nbmerge = callPackage ../development/python-modules/nbmerge { };

  nbxmpp = callPackage ../development/python-modules/nbxmpp { };

  sleekxmpp = callPackage ../development/python-modules/sleekxmpp { };

  slixmpp = callPackage ../development/python-modules/slixmpp {
    inherit (pkgs) gnupg;
  };

  netaddr = callPackage ../development/python-modules/netaddr { };

  netifaces = callPackage ../development/python-modules/netifaces { };

  hpack = callPackage ../development/python-modules/hpack { };

  nevow = callPackage ../development/python-modules/nevow { };

  nibabel = callPackage ../development/python-modules/nibabel {};

  nilearn = callPackage ../development/python-modules/nilearn {};

  nimfa = callPackage ../development/python-modules/nimfa {};

  nipy = callPackage ../development/python-modules/nipy { };

  nipype = callPackage ../development/python-modules/nipype {
    inherit (pkgs) which;
  };

  nixpkgs = callPackage ../development/python-modules/nixpkgs { };

  nodeenv = callPackage ../development/python-modules/nodeenv { };

  nose = callPackage ../development/python-modules/nose { };

  nose-cov = callPackage ../development/python-modules/nose-cov { };

  nose-exclude = callPackage ../development/python-modules/nose-exclude { };

  nose-focus = callPackage ../development/python-modules/nose-focus { };

  nose-randomly = callPackage ../development/python-modules/nose-randomly { };

  nose2 = callPackage ../development/python-modules/nose2 { };

  nose-cover3 = callPackage ../development/python-modules/nose-cover3 { };

  nosexcover = callPackage ../development/python-modules/nosexcover { };

  nosejs = callPackage ../development/python-modules/nosejs { };

  nose-cprof = callPackage ../development/python-modules/nose-cprof { };

  nose-of-yeti = callPackage ../development/python-modules/nose-of-yeti { };

  nose-pattern-exclude = callPackage ../development/python-modules/nose-pattern-exclude { };

  nose_warnings_filters = callPackage ../development/python-modules/nose_warnings_filters { };

  notebook = callPackage ../development/python-modules/notebook { };

  notify = callPackage ../development/python-modules/notify { };

  notify2 = callPackage ../development/python-modules/notify2 {};

  notmuch = callPackage ../development/python-modules/notmuch { };

  emoji = callPackage ../development/python-modules/emoji { };

  ntplib = callPackage ../development/python-modules/ntplib { };

  numba = callPackage ../development/python-modules/numba { };

  numexpr = callPackage ../development/python-modules/numexpr { };

  Nuitka = callPackage ../development/python-modules/nuitka { };

  numpy = callPackage ../development/python-modules/numpy {
    blas = pkgs.openblasCompat;
  };

  numpydoc = callPackage ../development/python-modules/numpydoc { };

  numpy-stl = callPackage ../development/python-modules/numpy-stl { };

  numtraits = callPackage ../development/python-modules/numtraits { };

  nwdiag = callPackage ../development/python-modules/nwdiag { };

  dynd = callPackage ../development/python-modules/dynd { };

  langcodes = callPackage ../development/python-modules/langcodes { };

  livestreamer = callPackage ../development/python-modules/livestreamer { };

  livestreamer-curses = callPackage ../development/python-modules/livestreamer-curses { };

  oauth = callPackage ../development/python-modules/oauth { };

  oauth2 = callPackage ../development/python-modules/oauth2 { };

  oauth2client = callPackage ../development/python-modules/oauth2client { };

  oauthlib = callPackage ../development/python-modules/oauthlib { };

  obfsproxy = callPackage ../development/python-modules/obfsproxy { };

  objgraph = callPackage ../development/python-modules/objgraph {
    graphvizPkg = pkgs.graphviz;
  };

  odo = callPackage ../development/python-modules/odo { };

  offtrac = callPackage ../development/python-modules/offtrac { };

  openpyxl = callPackage ../development/python-modules/openpyxl { };

  opentimestamps = callPackage ../development/python-modules/opentimestamps { };

  ordereddict = callPackage ../development/python-modules/ordereddict { };

  od = callPackage ../development/python-modules/od { };

  orderedset = callPackage ../development/python-modules/orderedset { };

  python-otr = callPackage ../development/python-modules/python-otr { };

  plone-testing = callPackage ../development/python-modules/plone-testing { };

  ply = callPackage ../development/python-modules/ply { };

  plyplus = callPackage ../development/python-modules/plyplus { };

  plyvel = callPackage ../development/python-modules/plyvel { };

  osc = callPackage ../development/python-modules/osc { };

  rfc3986 = callPackage ../development/python-modules/rfc3986 { };

   cachetools_1 = callPackage ../development/python-modules/cachetools/1.nix {};
   cachetools = callPackage ../development/python-modules/cachetools {};

  cmd2_8 = callPackage ../development/python-modules/cmd2/old.nix {};
  cmd2_9 = callPackage ../development/python-modules/cmd2 {};
  cmd2 = if isPy27 then self.cmd2_8 else self.cmd2_9;

  warlock = callPackage ../development/python-modules/warlock { };

  pecan = callPackage ../development/python-modules/pecan { };

  kaitaistruct = callPackage ../development/python-modules/kaitaistruct { };

  Kajiki = callPackage ../development/python-modules/kajiki { };

  WSME = callPackage ../development/python-modules/WSME { };

  zake = callPackage ../development/python-modules/zake { };

  kazoo = callPackage ../development/python-modules/kazoo { };

  FormEncode = callPackage ../development/python-modules/FormEncode { };

  pycountry = callPackage ../development/python-modules/pycountry { };

  nine = callPackage ../development/python-modules/nine { };

  logutils = callPackage ../development/python-modules/logutils { };

  ldappool = callPackage ../development/python-modules/ldappool { };

  retrying = callPackage ../development/python-modules/retrying { };

  fasteners = callPackage ../development/python-modules/fasteners { };

  aioeventlet = callPackage ../development/python-modules/aioeventlet { };

  olefile = callPackage ../development/python-modules/olefile { };

  requests-mock = callPackage ../development/python-modules/requests-mock { };

  mecab-python3 = callPackage ../development/python-modules/mecab-python3 { };

  mox3 = callPackage ../development/python-modules/mox3 { };

  doc8 = callPackage ../development/python-modules/doc8 { };

  wrapt = callPackage ../development/python-modules/wrapt { };

  pagerduty = callPackage ../development/python-modules/pagerduty { };

  pandas = callPackage ../development/python-modules/pandas { };

  pandas_0_17_1 = callPackage ../development/python-modules/pandas/0.17.1.nix { };

  xlrd = callPackage ../development/python-modules/xlrd { };

  bottleneck = callPackage ../development/python-modules/bottleneck { };

  paho-mqtt = callPackage ../development/python-modules/paho-mqtt { };

  pamqp = callPackage ../development/python-modules/pamqp { };

  parsedatetime = callPackage ../development/python-modules/parsedatetime { };

  paramiko = callPackage ../development/python-modules/paramiko { };

  parameterized = callPackage ../development/python-modules/parameterized { };

  paramz = callPackage ../development/python-modules/paramz { };

  parsel = callPackage ../development/python-modules/parsel { };

  parso = callPackage ../development/python-modules/parso { };

  partd = callPackage ../development/python-modules/partd { };

  patch = callPackage ../development/python-modules/patch { };

  pathos = callPackage ../development/python-modules/pathos { };

  patsy = callPackage ../development/python-modules/patsy { };

  paste = callPackage ../development/python-modules/paste { };

  PasteDeploy = callPackage ../development/python-modules/pastedeploy { };

  pasteScript = callPackage ../development/python-modules/pastescript { };

  patator = callPackage ../development/python-modules/patator { };

  pathlib2 = callPackage ../development/python-modules/pathlib2 { };

  pathpy = callPackage ../development/python-modules/path.py { };

  paypalrestsdk = callPackage ../development/python-modules/paypalrestsdk { };

  pbr = callPackage ../development/python-modules/pbr { };

  fixtures = callPackage ../development/python-modules/fixtures { };

  pelican = callPackage ../development/python-modules/pelican {
    inherit (pkgs) glibcLocales git;
  };

  pep8 = callPackage ../development/python-modules/pep8 { };

  pep257 = callPackage ../development/python-modules/pep257 { };

  percol = callPackage ../development/python-modules/percol { };

  pexif = callPackage ../development/python-modules/pexif { };

  pexpect = callPackage ../development/python-modules/pexpect { };

  pdfkit = callPackage ../development/python-modules/pdfkit { };

  periodictable = callPackage ../development/python-modules/periodictable { };

  pg8000 = callPackage ../development/python-modules/pg8000 { };

  pgsanity = callPackage ../development/python-modules/pgsanity { };

  pgspecial = callPackage ../development/python-modules/pgspecial { };

  pickleshare = callPackage ../development/python-modules/pickleshare { };

  piep = callPackage ../development/python-modules/piep { };

  piexif = callPackage ../development/python-modules/piexif { };

  pip = callPackage ../development/python-modules/pip { };

  pip-tools = callPackage ../development/python-modules/pip-tools {
    git = pkgs.gitMinimal;
    glibcLocales = pkgs.glibcLocales;
  };

  pika = callPackage ../development/python-modules/pika { };

  pika-pool = callPackage ../development/python-modules/pika-pool { };

  kmsxx = (callPackage ../development/libraries/kmsxx {
    inherit (pkgs.kmsxx) stdenv;
  }).overrideAttrs (oldAttrs: {
    name = "${python.libPrefix}-${pkgs.kmsxx.name}";
  });

  pvlib = callPackage ../development/python-modules/pvlib { };

  pybase64 = callPackage ../development/python-modules/pybase64 { };

  pylibconfig2 = callPackage ../development/python-modules/pylibconfig2 { };

  pylibmc = callPackage ../development/python-modules/pylibmc {};

  pymetar = callPackage ../development/python-modules/pymetar { };

  pysftp = callPackage ../development/python-modules/pysftp { };

  pysoundfile = callPackage ../development/python-modules/pysoundfile { };

  python3pika = callPackage ../development/python-modules/python3pika { };

  python-jenkins = callPackage ../development/python-modules/python-jenkins { };

  pystringtemplate = callPackage ../development/python-modules/stringtemplate { };

  pillow = callPackage ../development/python-modules/pillow {
    inherit (pkgs) freetype libjpeg zlib libtiff libwebp tcl lcms2 tk;
    inherit (pkgs.xorg) libX11;
  };

  pkgconfig = callPackage ../development/python-modules/pkgconfig {
    inherit (pkgs) pkgconfig;
  };

  plumbum = callPackage ../development/python-modules/plumbum { };

  polib = callPackage ../development/python-modules/polib {};

  posix_ipc = callPackage ../development/python-modules/posix_ipc { };

  portend = callPackage ../development/python-modules/portend { };

  powerline = callPackage ../development/python-modules/powerline { };

  pox = callPackage ../development/python-modules/pox { };

  ppft = callPackage ../development/python-modules/ppft { };

  praw = callPackage ../development/python-modules/praw { };

  prawcore = callPackage ../development/python-modules/prawcore { };

  premailer = callPackage ../development/python-modules/premailer { };

  prettytable = callPackage ../development/python-modules/prettytable { };

  prompt_toolkit = let
    filename = if isPy3k then ../development/python-modules/prompt_toolkit else ../development/python-modules/prompt_toolkit/1.nix;
  in callPackage filename { };

  protobuf = callPackage ../development/python-modules/protobuf {
    disabled = isPyPy;
    doCheck = !isPy3k;
    protobuf = pkgs.protobuf;
  };

  psd-tools = callPackage ../development/python-modules/psd-tools { };

  psutil = callPackage ../development/python-modules/psutil { };

  psycopg2 = callPackage ../development/python-modules/psycopg2 {};

  ptpython = callPackage ../development/python-modules/ptpython {
    prompt_toolkit = self.prompt_toolkit;
  };

  publicsuffix = callPackage ../development/python-modules/publicsuffix {};

  py = callPackage ../development/python-modules/py { };

  pyacoustid = callPackage ../development/python-modules/pyacoustid { };

  pyalgotrade = callPackage ../development/python-modules/pyalgotrade { };

  pyasn1 = callPackage ../development/python-modules/pyasn1 { };

  pyasn1-modules = callPackage ../development/python-modules/pyasn1-modules { };

  pyaudio = callPackage ../development/python-modules/pyaudio { };

  pysam = callPackage ../development/python-modules/pysam { };

  pysaml2 = callPackage ../development/python-modules/pysaml2 {
    inherit (pkgs) xmlsec;
  };

  python-pushover = callPackage ../development/python-modules/pushover {};

  pystemd = callPackage ../development/python-modules/pystemd { systemd = pkgs.systemd; };

  mongodict = callPackage ../development/python-modules/mongodict { };

  repoze_who = callPackage ../development/python-modules/repoze_who { };

  vobject = callPackage ../development/python-modules/vobject { };

  pycarddav = callPackage ../development/python-modules/pycarddav { };

  pygit2 = callPackage ../development/python-modules/pygit2 { };

  Babel = callPackage ../development/python-modules/Babel { };

  pybfd = callPackage ../development/python-modules/pybfd { };

  pyblock = callPackage ../development/python-modules/pyblock { };

  pybcrypt = callPackage ../development/python-modules/pybcrypt { };

  pyblosxom = callPackage ../development/python-modules/pyblosxom { };

  pycapnp = callPackage ../development/python-modules/pycapnp { };

  pycaption = callPackage ../development/python-modules/pycaption { };

  pycdio = callPackage ../development/python-modules/pycdio { };

  pycosat = callPackage ../development/python-modules/pycosat { };

  pycryptopp = callPackage ../development/python-modules/pycryptopp { };

  pycups = callPackage ../development/python-modules/pycups { };

  pycurl = callPackage ../development/python-modules/pycurl { };

  pycurl2 = callPackage ../development/python-modules/pycurl2 { };

  pydispatcher = callPackage ../development/python-modules/pydispatcher { };

  pydot = callPackage ../development/python-modules/pydot {
    inherit (pkgs) graphviz;
  };

  pydot_ng = callPackage ../development/python-modules/pydot_ng { };

  pyelftools = callPackage ../development/python-modules/pyelftools { };

  pyenchant = callPackage ../development/python-modules/pyenchant { };

  pyev = callPackage ../development/python-modules/pyev { };

  pyexcelerator = callPackage ../development/python-modules/pyexcelerator { };

  pyext = callPackage ../development/python-modules/pyext { };

  pyfantom = callPackage ../development/python-modules/pyfantom { };

  pyfftw = callPackage ../development/python-modules/pyfftw { };

  pyfiglet = callPackage ../development/python-modules/pyfiglet { };

  pyflakes = callPackage ../development/python-modules/pyflakes { };

  pyftgl = callPackage ../development/python-modules/pyftgl { };

  pygeoip = callPackage ../development/python-modules/pygeoip {};

  PyGithub = callPackage ../development/python-modules/pyGithub {};

  pyglet = callPackage ../development/python-modules/pyglet {};

  pygments = callPackage ../development/python-modules/Pygments { };

  pygpgme = callPackage ../development/python-modules/pygpgme { };

  pyment = callPackage ../development/python-modules/pyment { };

  pylint = if isPy3k then callPackage ../development/python-modules/pylint { }
           else callPackage ../development/python-modules/pylint/1.9.nix { };

  pyopencl = callPackage ../development/python-modules/pyopencl { };

  pyotp = callPackage ../development/python-modules/pyotp { };

  pyproj = callPackage ../development/python-modules/pyproj {
    # pyproj does *work* if you want to use a system supplied proj, but with the current version(s) the tests fail by
    # a few decimal places, so caveat emptor.
    proj = null;
  };

  pyqrcode = callPackage ../development/python-modules/pyqrcode { };

  pyrr = callPackage ../development/python-modules/pyrr { };

  pysha3 = callPackage ../development/python-modules/pysha3 { };

  pyshp = callPackage ../development/python-modules/pyshp { };

  pysmbc = callPackage ../development/python-modules/pysmbc { };

  pyspread = callPackage ../development/python-modules/pyspread { };

  pyupdate = callPackage ../development/python-modules/pyupdate {};

  pyx = callPackage ../development/python-modules/pyx { };

  mmpython = callPackage ../development/python-modules/mmpython { };

  kaa-base = callPackage ../development/python-modules/kaa-base { };

  kaa-metadata = callPackage ../development/python-modules/kaa-metadata { };

  PyICU = callPackage ../development/python-modules/pyicu { };

  pyinputevent = callPackage ../development/python-modules/pyinputevent { };

  pyinotify = callPackage ../development/python-modules/pyinotify { };

  pyinsane2 = callPackage ../development/python-modules/pyinsane2 { };

  pyjwt = callPackage ../development/python-modules/pyjwt { };

  pykickstart = callPackage ../development/python-modules/pykickstart { };

  pyobjc = if stdenv.isDarwin
    then callPackage ../development/python-modules/pyobjc {}
    else throw "pyobjc can only be built on Mac OS";

  pyodbc = callPackage ../development/python-modules/pyodbc { };

  pyocr = callPackage ../development/python-modules/pyocr { };

  pyparsing = callPackage ../development/python-modules/pyparsing { };

  pyparted = callPackage ../development/python-modules/pyparted { };

  pyptlib = callPackage ../development/python-modules/pyptlib { };

  pyqtgraph = callPackage ../development/python-modules/pyqtgraph { };

  PyStemmer = callPackage ../development/python-modules/pystemmer {};

  # Missing expression?
  # Pyro = callPackage ../development/python-modules/pyro { };

  pyrsistent = callPackage ../development/python-modules/pyrsistent { };

  PyRSS2Gen = callPackage ../development/python-modules/pyrss2gen { };

  pysmi = callPackage ../development/python-modules/pysmi { };

  pysnmp = callPackage ../development/python-modules/pysnmp { };

  pysocks = callPackage ../development/python-modules/pysocks { };

  python_fedora = callPackage ../development/python-modules/python_fedora {};

  python-simple-hipchat = callPackage ../development/python-modules/python-simple-hipchat {};
  python_simple_hipchat = self.python-simple-hipchat;

  python_keyczar = callPackage ../development/python-modules/python_keyczar { };

  python-language-server = callPackage ../development/python-modules/python-language-server {};

  python-jsonrpc-server = callPackage ../development/python-modules/python-jsonrpc-server {};

  pyls-black = callPackage ../development/python-modules/pyls-black {};

  pyls-isort = callPackage ../development/python-modules/pyls-isort {};

  pyls-mypy = callPackage ../development/python-modules/pyls-mypy {};

  pyudev = callPackage ../development/python-modules/pyudev {
    inherit (pkgs) systemd;
  };

  pynmea2 = callPackage ../development/python-modules/pynmea2 {};

  pynzb = callPackage ../development/python-modules/pynzb { };

  process-tests = callPackage ../development/python-modules/process-tests { };

  progressbar = callPackage ../development/python-modules/progressbar {};

  progressbar2 = callPackage ../development/python-modules/progressbar2 { };

  progressbar231 = callPackage ../development/python-modules/progressbar231 { };

  progressbar33 = callPackage ../development/python-modules/progressbar33 { };

  ldap = callPackage ../development/python-modules/ldap {
    inherit (pkgs) openldap cyrus_sasl;
  };

  ldap3 = callPackage ../development/python-modules/ldap3 {};

  ptest = callPackage ../development/python-modules/ptest { };

  ptyprocess = callPackage ../development/python-modules/ptyprocess { };

  pylibacl = callPackage ../development/python-modules/pylibacl { };

  pylibgen = callPackage ../development/python-modules/pylibgen { };

  pyliblo = callPackage ../development/python-modules/pyliblo { };

  pypcap = callPackage ../development/python-modules/pypcap {};

  pyplatec = callPackage ../development/python-modules/pyplatec { };

  purepng = callPackage ../development/python-modules/purepng { };

  pymaging = callPackage ../development/python-modules/pymaging { };

  pymaging_png = callPackage ../development/python-modules/pymaging_png { };

  pyPdf = callPackage ../development/python-modules/pypdf { };

  pypdf2 = callPackage ../development/python-modules/pypdf2 { };

  pyopengl = callPackage ../development/python-modules/pyopengl { };

  pyopenssl = callPackage ../development/python-modules/pyopenssl { };

  pyquery = callPackage ../development/python-modules/pyquery { };

  pyreport = callPackage ../development/python-modules/pyreport { };

  pyreadability = callPackage ../development/python-modules/pyreadability { };

  pyscss = callPackage ../development/python-modules/pyscss { };

  pyserial = callPackage ../development/python-modules/pyserial {};

  pymongo = callPackage ../development/python-modules/pymongo {};

  pymongo_2_9_1 = callPackage ../development/python-modules/pymongo/2_9_1.nix { };

  pyperclip = callPackage ../development/python-modules/pyperclip { };

  pysqlite = callPackage ../development/python-modules/pysqlite { };

  pysvn = callPackage ../development/python-modules/pysvn { };

  python-ptrace = callPackage ../development/python-modules/python-ptrace { };

  python-wifi = callPackage ../development/python-modules/python-wifi { };

  python-etcd = callPackage ../development/python-modules/python-etcd { };

  pythonnet = callPackage ../development/python-modules/pythonnet {
    # `mono >= 4.6` required to prevent crashes encountered with earlier versions.
    mono = pkgs.mono4;
  };

  pytz = callPackage ../development/python-modules/pytz { };

  pytzdata = callPackage ../development/python-modules/pytzdata { };

  pyutil = callPackage ../development/python-modules/pyutil { };

  pywal = callPackage ../development/python-modules/pywal { };

  pywebkitgtk = callPackage ../development/python-modules/pywebkitgtk { };

  pywinrm = callPackage ../development/python-modules/pywinrm { };

  pyxattr = callPackage ../development/python-modules/pyxattr { };

  pyaml = callPackage ../development/python-modules/pyaml { };

  pyyaml = callPackage ../development/python-modules/pyyaml { };

  rabbitpy = callPackage ../development/python-modules/rabbitpy { };

  rasterio = callPackage ../development/python-modules/rasterio { };

  radicale_infcloud = callPackage ../development/python-modules/radicale_infcloud {};

  recaptcha_client = callPackage ../development/python-modules/recaptcha_client { };

  rbtools = callPackage ../development/python-modules/rbtools { };

  rencode = callPackage ../development/python-modules/rencode { };

  reportlab = callPackage ../development/python-modules/reportlab { };

  requests2 = throw "requests2 has been deprecated. Use requests instead.";

  # use requests, not requests_2
  requests = callPackage ../development/python-modules/requests { };

  requests_download = callPackage ../development/python-modules/requests_download { };

  requestsexceptions = callPackage ../development/python-modules/requestsexceptions {};

  requests_ntlm = callPackage ../development/python-modules/requests_ntlm { };

  requests_oauthlib = callPackage ../development/python-modules/requests-oauthlib { };

  requests-toolbelt = callPackage ../development/python-modules/requests-toolbelt { };
  requests_toolbelt = self.requests-toolbelt; # Old attr, 2017-09-26

  retry_decorator = callPackage ../development/python-modules/retry_decorator { };

  quandl = callPackage ../development/python-modules/quandl { };
  # alias for an older package which did not support Python 3
  Quandl = callPackage ../development/python-modules/quandl { };

  qscintilla = callPackage ../development/python-modules/qscintilla { };

  qserve = callPackage ../development/python-modules/qserve { };

  qtawesome = callPackage ../development/python-modules/qtawesome { };

  qtconsole = callPackage ../development/python-modules/qtconsole { };

  qtpy = callPackage ../development/python-modules/qtpy { };

  quantities = callPackage ../development/python-modules/quantities { };

  qutip = callPackage ../development/python-modules/qutip { };

  rcssmin = callPackage ../development/python-modules/rcssmin { };

  recommonmark = callPackage ../development/python-modules/recommonmark { };

  redis = callPackage ../development/python-modules/redis { };

  rednose = callPackage ../development/python-modules/rednose { };

  reikna = callPackage ../development/python-modules/reikna { };

  repocheck = callPackage ../development/python-modules/repocheck { };

  restview = callPackage ../development/python-modules/restview { };

  readme = callPackage ../development/python-modules/readme { };

  readme_renderer = callPackage ../development/python-modules/readme_renderer { };

  rivet = disabledIf isPy3k (toPythonModule (pkgs.rivet.override {
    python2 = python;
  }));

  rjsmin = callPackage ../development/python-modules/rjsmin { };

  pysolr = callPackage ../development/python-modules/pysolr { };

  geoalchemy2 = callPackage ../development/python-modules/geoalchemy2 { };

  geopy = callPackage ../development/python-modules/geopy { };

  django-haystack = callPackage ../development/python-modules/django-haystack { };

  django-multiselectfield = callPackage ../development/python-modules/django-multiselectfield { };

  rdflib = callPackage ../development/python-modules/rdflib { };

  isodate = callPackage ../development/python-modules/isodate { };

  owslib = callPackage ../development/python-modules/owslib { };

  resampy = callPackage ../development/python-modules/resampy { };

  restructuredtext_lint = callPackage ../development/python-modules/restructuredtext_lint { };

  robomachine = callPackage ../development/python-modules/robomachine { };

  robotframework = callPackage ../development/python-modules/robotframework { };

  robotframework-requests = callPackage ../development/python-modules/robotframework-requests { };

  robotframework-ride = callPackage ../development/python-modules/robotframework-ride { };

  robotframework-seleniumlibrary = callPackage ../development/python-modules/robotframework-seleniumlibrary { };

  robotframework-selenium2library = callPackage ../development/python-modules/robotframework-selenium2library { };

  robotframework-tools = callPackage ../development/python-modules/robotframework-tools { };

  robotstatuschecker = callPackage ../development/python-modules/robotstatuschecker { };

  robotsuite = callPackage ../development/python-modules/robotsuite { };

  serpent = callPackage ../development/python-modules/serpent { };

  selectors34 = callPackage ../development/python-modules/selectors34 { };

  Pyro4 = callPackage ../development/python-modules/pyro4 { };

  root_numpy = callPackage ../development/python-modules/root_numpy { };

  rootpy = callPackage ../development/python-modules/rootpy { };

  rope = callPackage ../development/python-modules/rope { };

  ropper = callPackage ../development/python-modules/ropper { };

  rpkg = callPackage ../development/python-modules/rpkg {};

  rply = callPackage ../development/python-modules/rply {};

  rpm = toPythonModule (pkgs.rpm.override{inherit python;});

  rpmfluff = callPackage ../development/python-modules/rpmfluff {};

  rpy2 = callPackage ../development/python-modules/rpy2 {};

  rtslib = callPackage ../development/python-modules/rtslib {};

  Rtree = callPackage ../development/python-modules/Rtree { inherit (pkgs) libspatialindex; };

  typing = callPackage ../development/python-modules/typing { };

  typing-extensions = callPackage ../development/python-modules/typing-extensions { };

  typeguard = callPackage ../development/python-modules/typeguard { };

  s3transfer = callPackage ../development/python-modules/s3transfer { };

  seqdiag = callPackage ../development/python-modules/seqdiag { };

  safe = callPackage ../development/python-modules/safe { };

  sampledata = callPackage ../development/python-modules/sampledata { };

  sasmodels = callPackage ../development/python-modules/sasmodels { };

  scapy = callPackage ../development/python-modules/scapy { };

  scipy = callPackage ../development/python-modules/scipy { };

  scikitimage = callPackage ../development/python-modules/scikit-image { };

  scikitlearn = callPackage ../development/python-modules/scikitlearn {
    inherit (pkgs) gfortran glibcLocales;
  };

  scikit-bio = callPackage ../development/python-modules/scikit-bio { };

  scp = callPackage ../development/python-modules/scp {};

  seaborn = callPackage ../development/python-modules/seaborn { };

  selenium = callPackage ../development/python-modules/selenium { };

  serpy = callPackage ../development/python-modules/serpy { };

  setuptools_scm = callPackage ../development/python-modules/setuptools_scm { };

  shippai = callPackage ../development/python-modules/shippai {};

  simanneal = callPackage ../development/python-modules/simanneal { };

  simplegeneric = callPackage ../development/python-modules/simplegeneric { };

  should-dsl = callPackage ../development/python-modules/should-dsl { };

  simplejson = callPackage ../development/python-modules/simplejson { };

  simplekml = callPackage ../development/python-modules/simplekml { };

  slimit = callPackage ../development/python-modules/slimit { };

  snowballstemmer = callPackage ../development/python-modules/snowballstemmer { };

  snscrape = callPackage ../development/python-modules/snscrape { };

  snug = callPackage ../development/python-modules/snug { };

  snuggs = callPackage ../development/python-modules/snuggs { };

  spake2 = callPackage ../development/python-modules/spake2 { };

  sphfile = callPackage ../development/python-modules/sphfile { };

  supervisor = callPackage ../development/python-modules/supervisor {};

  subprocess32 = callPackage ../development/python-modules/subprocess32 { };

  spark_parser = callPackage ../development/python-modules/spark_parser { };

  sphinx = callPackage ../development/python-modules/sphinx { };

  sphinxcontrib-websupport = callPackage ../development/python-modules/sphinxcontrib-websupport { };

  hieroglyph = callPackage ../development/python-modules/hieroglyph { };

  guzzle_sphinx_theme = callPackage ../development/python-modules/guzzle_sphinx_theme { };

  sphinx-testing = callPackage ../development/python-modules/sphinx-testing { };

  sphinxcontrib-bibtex = callPackage ../development/python-modules/sphinxcontrib-bibtex {};

  sphinx-navtree = callPackage ../development/python-modules/sphinx-navtree {};

  sphinx-jinja = callPackage ../development/python-modules/sphinx-jinja { };

  splinter = callPackage ../development/python-modules/splinter { };

  spotipy = callPackage ../development/python-modules/spotipy { };

  sqlalchemy = callPackage ../development/python-modules/sqlalchemy { };

  sqlalchemy_migrate = callPackage ../development/python-modules/sqlalchemy-migrate { };

  staticjinja = callPackage ../development/python-modules/staticjinja { };

  statsmodels = callPackage ../development/python-modules/statsmodels { };

  structlog = callPackage ../development/python-modules/structlog { };

  sybil = callPackage ../development/python-modules/sybil { };

  # legacy alias
  syncthing-gtk = pkgs.syncthing-gtk;

  systemd = callPackage ../development/python-modules/systemd {
    inherit (pkgs) pkgconfig systemd;
  };

  tabulate = callPackage ../development/python-modules/tabulate { };

  tempita = callPackage ../development/python-modules/tempita { };

  terminado = callPackage ../development/python-modules/terminado { };

  testresources = callPackage ../development/python-modules/testresources { };

  testtools = callPackage ../development/python-modules/testtools { };

  traitlets = callPackage ../development/python-modules/traitlets { };

  transitions = callPackage ../development/python-modules/transitions { };

  extras = callPackage ../development/python-modules/extras { };

  texttable = callPackage ../development/python-modules/texttable { };

  tiros = callPackage ../development/python-modules/tiros { };

  tifffile = callPackage ../development/python-modules/tifffile { };

  tmdb3 = callPackage ../development/python-modules/tmdb3 { };

  toolz = callPackage ../development/python-modules/toolz { };

  tox = callPackage ../development/python-modules/tox { };

  tqdm = callPackage ../development/python-modules/tqdm { };

  smmap = callPackage ../development/python-modules/smmap { };

  smmap2 = callPackage ../development/python-modules/smmap2 { };

  transaction = callPackage ../development/python-modules/transaction { };

  TurboCheetah = callPackage ../development/python-modules/TurboCheetah { };

  tweepy = callPackage ../development/python-modules/tweepy { };

  twill = callPackage ../development/python-modules/twill { };

  twine = callPackage ../development/python-modules/twine { };

  twisted = callPackage ../development/python-modules/twisted { };

  txtorcon = callPackage ../development/python-modules/txtorcon { };

  tzlocal = callPackage ../development/python-modules/tzlocal { };

  u-msgpack-python = callPackage ../development/python-modules/u-msgpack-python { };

  ua-parser = callPackage ../development/python-modules/ua-parser { };

  uarray = callPackage ../development/python-modules/uarray { };

  ukpostcodeparser = callPackage ../development/python-modules/ukpostcodeparser { };

  umemcache = callPackage ../development/python-modules/umemcache {};

  uritools = callPackage ../development/python-modules/uritools { };

  update_checker = callPackage ../development/python-modules/update_checker {};

  update-copyright = callPackage ../development/python-modules/update-copyright {};

  uritemplate = callPackage ../development/python-modules/uritemplate { };

  uproot = callPackage ../development/python-modules/uproot {};

  uproot-methods = callPackage ../development/python-modules/uproot-methods { };

  urlgrabber = callPackage ../development/python-modules/urlgrabber {};

  urwid = callPackage ../development/python-modules/urwid {};

  user-agents = callPackage ../development/python-modules/user-agents { };

  vega_datasets = callPackage ../development/python-modules/vega_datasets { };

  virtkey = callPackage ../development/python-modules/virtkey { };

  virtual-display = callPackage ../development/python-modules/virtual-display { };

  virtualenv = callPackage ../development/python-modules/virtualenv { };

  webassets = callPackage ../development/python-modules/webassets { };

  webcolors = callPackage ../development/python-modules/webcolors { };

  webencodings = callPackage ../development/python-modules/webencodings { };

  websockets = callPackage ../development/python-modules/websockets { };

  Wand = callPackage ../development/python-modules/Wand {
    imagemagick = pkgs.imagemagickBig;
  };

  wcwidth = callPackage ../development/python-modules/wcwidth { };

  werkzeug = callPackage ../development/python-modules/werkzeug { };

  wheel = callPackage ../development/python-modules/wheel { };

  widgetsnbextension = callPackage ../development/python-modules/widgetsnbextension { };

  wordfreq = callPackage ../development/python-modules/wordfreq { };

  magic-wormhole = callPackage ../development/python-modules/magic-wormhole { };

  magic-wormhole-mailbox-server = callPackage ../development/python-modules/magic-wormhole-mailbox-server { };

  magic-wormhole-transit-relay = callPackage ../development/python-modules/magic-wormhole-transit-relay { };

  wxPython = self.wxPython30;

  wxPython30 = callPackage ../development/python-modules/wxPython/3.0.nix {
    wxGTK = pkgs.wxGTK30;
  };

  xml2rfc = callPackage ../development/python-modules/xml2rfc { };

  xmltodict = callPackage ../development/python-modules/xmltodict { };

  xarray = callPackage ../development/python-modules/xarray { };

  xlwt = callPackage ../development/python-modules/xlwt { };

  youtube-dl = callPackage ../tools/misc/youtube-dl {};

  youtube-dl-light = callPackage ../tools/misc/youtube-dl {
    ffmpegSupport = false;
    phantomjsSupport = false;
  };

  zconfig = callPackage ../development/python-modules/zconfig { };

  zc_lockfile = callPackage ../development/python-modules/zc_lockfile { };

  zipstream = callPackage ../development/python-modules/zipstream { };

  zodb = callPackage ../development/python-modules/zodb {};

  zodbpickle = callPackage ../development/python-modules/zodbpickle {};

  BTrees = callPackage ../development/python-modules/btrees {};

  persistent = callPackage ../development/python-modules/persistent {};

  xdot = callPackage ../development/python-modules/xdot { };

  zetup = callPackage ../development/python-modules/zetup { };

  routes = callPackage ../development/python-modules/routes { };

  rpyc = callPackage ../development/python-modules/rpyc { };

  rsa = callPackage ../development/python-modules/rsa { };

  squaremap = callPackage ../development/python-modules/squaremap { };

  ruamel_base = callPackage ../development/python-modules/ruamel_base { };

  ruamel_ordereddict = callPackage ../development/python-modules/ruamel_ordereddict { };

  ruamel_yaml = callPackage ../development/python-modules/ruamel_yaml { };

  runsnakerun = callPackage ../development/python-modules/runsnakerun { };

  pysendfile = callPackage ../development/python-modules/pysendfile { };

  qpid-python = callPackage ../development/python-modules/qpid-python { };

  xattr = callPackage ../development/python-modules/xattr { };

  scripttest = callPackage ../development/python-modules/scripttest { };

  setuptoolsDarcs = callPackage ../development/python-modules/setuptoolsdarcs { };

  setuptoolsTrial = callPackage ../development/python-modules/setuptoolstrial { };

  simplebayes = callPackage ../development/python-modules/simplebayes { };

  shortuuid = callPackage ../development/python-modules/shortuuid { };

  shouldbe = callPackage ../development/python-modules/shouldbe { };

  simpleparse = callPackage ../development/python-modules/simpleparse { };

  slob = callPackage ../development/python-modules/slob { };

  slowaes = callPackage ../development/python-modules/slowaes { };

  sqlite3dbm = callPackage ../development/python-modules/sqlite3dbm { };

  sqlobject = callPackage ../development/python-modules/sqlobject { };

  sqlmap = callPackage ../development/python-modules/sqlmap { };

  pgpdump = callPackage ../development/python-modules/pgpdump { };

  spambayes = callPackage ../development/python-modules/spambayes { };

  shapely = callPackage ../development/python-modules/shapely { };

  sharedmem = callPackage ../development/python-modules/sharedmem { };

  soco = callPackage ../development/python-modules/soco { };

  sopel = callPackage ../development/python-modules/sopel { };

  sounddevice = callPackage ../development/python-modules/sounddevice { };

  stevedore = callPackage ../development/python-modules/stevedore {};

  text-unidecode = callPackage ../development/python-modules/text-unidecode { };

  Theano = callPackage ../development/python-modules/Theano rec {
    cudaSupport = pkgs.config.cudaSupport or false;
    cudnnSupport = cudaSupport;
    inherit (pkgs.linuxPackages) nvidia_x11;
  };

  TheanoWithoutCuda = self.Theano.override {
    cudaSupport = false;
    cudnnSupport = false;
  };

  TheanoWithCuda = self.Theano.override {
    cudaSupport = true;
    cudnnSupport = true;
  };

  thespian = callPackage ../development/python-modules/thespian { };

  tidylib = callPackage ../development/python-modules/pytidylib { };

  tilestache = callPackage ../development/python-modules/tilestache { };

  timelib = callPackage ../development/python-modules/timelib { };

  timeout-decorator = callPackage ../development/python-modules/timeout-decorator { };

  pid = callPackage ../development/python-modules/pid { };

  pip2nix = callPackage ../development/python-modules/pip2nix { };

  pychef = callPackage ../development/python-modules/pychef { };

  pydns =
    let
      py3 = callPackage ../development/python-modules/py3dns { };

      py2 = callPackage ../development/python-modules/pydns { };
    in if isPy3k then py3 else py2;

  python-daemon = callPackage ../development/python-modules/python-daemon { };

  sympy = callPackage ../development/python-modules/sympy { };

  pilkit = callPackage ../development/python-modules/pilkit { };

  clint = callPackage ../development/python-modules/clint { };

  argh = callPackage ../development/python-modules/argh { };

  nose_progressive = callPackage ../development/python-modules/nose_progressive { };

  blessings = callPackage ../development/python-modules/blessings { };

  secretstorage = if isPy3k
    then callPackage ../development/python-modules/secretstorage { }
    else callPackage ../development/python-modules/secretstorage/2.nix { };

  semantic = callPackage ../development/python-modules/semantic { };

  sandboxlib = callPackage ../development/python-modules/sandboxlib { };

  scales = callPackage ../development/python-modules/scales { };

  secp256k1 = callPackage ../development/python-modules/secp256k1 {
    inherit (pkgs) secp256k1 pkgconfig;
  };

  semantic-version = callPackage ../development/python-modules/semantic-version { };

  sexpdata = callPackage ../development/python-modules/sexpdata { };

  sh = callPackage ../development/python-modules/sh { };

  sipsimple = callPackage ../development/python-modules/sipsimple { };

  six = callPackage ../development/python-modules/six { };

  smartdc = callPackage ../development/python-modules/smartdc { };

  socksipy-branch = callPackage ../development/python-modules/socksipy-branch { };

  sockjs-tornado = callPackage ../development/python-modules/sockjs-tornado { };

  sorl_thumbnail = callPackage ../development/python-modules/sorl_thumbnail { };

  sphinx_rtd_theme = callPackage ../development/python-modules/sphinx_rtd_theme { };

  sphinxcontrib-blockdiag = callPackage ../development/python-modules/sphinxcontrib-blockdiag { };

  sphinxcontrib-openapi = callPackage ../development/python-modules/sphinxcontrib-openapi { };

  sphinxcontrib_httpdomain = callPackage ../development/python-modules/sphinxcontrib_httpdomain { };

  sphinxcontrib_newsfeed = callPackage ../development/python-modules/sphinxcontrib_newsfeed { };

  sphinxcontrib_plantuml = callPackage ../development/python-modules/sphinxcontrib_plantuml { };

  sphinxcontrib-spelling = callPackage ../development/python-modules/sphinxcontrib-spelling { };

  sphinx_pypi_upload = callPackage ../development/python-modules/sphinx_pypi_upload { };

  Pweave = callPackage ../development/python-modules/pweave { };

  SQLAlchemy-ImageAttach = callPackage ../development/python-modules/sqlalchemy-imageattach { };

  sqlparse = callPackage ../development/python-modules/sqlparse { };

  python_statsd = callPackage ../development/python-modules/python_statsd { };

  stompclient = callPackage ../development/python-modules/stompclient { };

  subdownloader = callPackage ../development/python-modules/subdownloader { };

  subunit = callPackage ../development/python-modules/subunit { };

  sure = callPackage ../development/python-modules/sure { };

  svgwrite = callPackage ../development/python-modules/svgwrite { };

  freezegun = callPackage ../development/python-modules/freezegun { };

  taskw = callPackage ../development/python-modules/taskw { };

  terminaltables = callPackage ../development/python-modules/terminaltables { };

  testpath = callPackage ../development/python-modules/testpath { };

  testrepository = callPackage ../development/python-modules/testrepository { };

  testscenarios = callPackage ../development/python-modules/testscenarios { };

  python_mimeparse = callPackage ../development/python-modules/python_mimeparse { };

  # Tkinter/tkinter is part of the Python standard library.
  # The Python interpreters in Nixpkgs come without tkinter by default.
  # To make the module available, we make it available as any other
  # Python package.
  tkinter = let
    py = python.override{x11Support=true;};
  in callPackage ../development/python-modules/tkinter { py = py; };

  tlslite-ng = callPackage ../development/python-modules/tlslite-ng { };

  qrcode = callPackage ../development/python-modules/qrcode { };

  traits = callPackage ../development/python-modules/traits { };

  transmissionrpc = callPackage ../development/python-modules/transmissionrpc { };

  eggdeps = callPackage ../development/python-modules/eggdeps { };

  twiggy = callPackage ../development/python-modules/twiggy { };

  twitter = callPackage ../development/python-modules/twitter { };

  twitter-common-collections = callPackage ../development/python-modules/twitter-common-collections { };

  twitter-common-confluence = callPackage ../development/python-modules/twitter-common-confluence { };

  twitter-common-dirutil = callPackage ../development/python-modules/twitter-common-dirutil { };

  twitter-common-lang = callPackage ../development/python-modules/twitter-common-lang { };

  twitter-common-log = callPackage ../development/python-modules/twitter-common-log { };

  twitter-common-options = callPackage ../development/python-modules/twitter-common-options { };

  umalqurra = callPackage ../development/python-modules/umalqurra { };

  unicodecsv = callPackage ../development/python-modules/unicodecsv { };

  unidiff = callPackage ../development/python-modules/unidiff { };

  unittest2 = callPackage ../development/python-modules/unittest2 { };

  unittest-xml-reporting = callPackage ../development/python-modules/unittest-xml-reporting { };

  traceback2 = callPackage ../development/python-modules/traceback2 { };

  linecache2 = callPackage ../development/python-modules/linecache2 { };

  upass = callPackage ../development/python-modules/upass { };

  uptime = callPackage ../development/python-modules/uptime { };

  urwidtrees = callPackage ../development/python-modules/urwidtrees { };

  pyuv = callPackage ../development/python-modules/pyuv { };

  virtualenv-clone = callPackage ../development/python-modules/virtualenv-clone { };

  virtualenvwrapper = callPackage ../development/python-modules/virtualenvwrapper { };

  vmprof = callPackage ../development/python-modules/vmprof { };

  vultr = callPackage ../development/python-modules/vultr { };

  waitress = callPackage ../development/python-modules/waitress { };

  waitress-django = callPackage ../development/python-modules/waitress-django { };

  web = callPackage ../development/python-modules/web { };

  webob = callPackage ../development/python-modules/webob { };

  websockify = callPackage ../development/python-modules/websockify { };

  webtest = callPackage ../development/python-modules/webtest { };

  wsgiproxy2 = callPackage ../development/python-modules/wsgiproxy2 { };

  xcaplib = callPackage ../development/python-modules/xcaplib { };

  xlib = callPackage ../development/python-modules/xlib { };

  zbase32 = callPackage ../development/python-modules/zbase32 { };

  zdaemon = callPackage ../development/python-modules/zdaemon { };

  zfec = callPackage ../development/python-modules/zfec { };

  zope_broken = callPackage ../development/python-modules/zope_broken { };

  zope_component = callPackage ../development/python-modules/zope_component { };

  zope_configuration = callPackage ../development/python-modules/zope_configuration { };

  zope_contenttype = callPackage ../development/python-modules/zope_contenttype { };

  zope-deferredimport = callPackage ../development/python-modules/zope-deferredimport { };

  zope_dottedname = callPackage ../development/python-modules/zope_dottedname { };

  zope_event = callPackage ../development/python-modules/zope_event { };

  zope_exceptions = callPackage ../development/python-modules/zope_exceptions { };

  zope_filerepresentation = callPackage ../development/python-modules/zope_filerepresentation { };

  zope-hookable = callPackage ../development/python-modules/zope-hookable { };

  zope_i18n = callPackage ../development/python-modules/zope_i18n { };

  zope_i18nmessageid = callPackage ../development/python-modules/zope_i18nmessageid { };

  zope_lifecycleevent = callPackage ../development/python-modules/zope_lifecycleevent { };

  zope_location = callPackage ../development/python-modules/zope_location { };

  zope_proxy = callPackage ../development/python-modules/zope_proxy { };

  zope_schema = callPackage ../development/python-modules/zope_schema { };

  zope_size = callPackage ../development/python-modules/zope_size { };

  zope_testing = callPackage ../development/python-modules/zope_testing { };

  zope_testrunner = callPackage ../development/python-modules/zope_testrunner { };

  zope_interface = callPackage ../development/python-modules/zope_interface { };

  hgsvn = callPackage ../development/python-modules/hgsvn { };

  cliapp = callPackage ../development/python-modules/cliapp { };

  cmdtest = callPackage ../development/python-modules/cmdtest { };

  tornado = callPackage ../development/python-modules/tornado { };
  tornado_4 = callPackage ../development/python-modules/tornado { version = "4.5.3"; };

  tokenlib = callPackage ../development/python-modules/tokenlib { };

  tunigo = callPackage ../development/python-modules/tunigo { };

  tarman = callPackage ../development/python-modules/tarman { };

  libarchive = self.python-libarchive; # The latter is the name upstream uses

  python-libarchive = callPackage ../development/python-modules/python-libarchive { };

  libarchive-c = callPackage ../development/python-modules/libarchive-c {
    inherit (pkgs) libarchive;
  };

  libasyncns = callPackage ../development/python-modules/libasyncns {
    inherit (pkgs) libasyncns pkgconfig;
  };

  pybrowserid = callPackage ../development/python-modules/pybrowserid { };

  pyzmq = callPackage ../development/python-modules/pyzmq { };

  testfixtures = callPackage ../development/python-modules/testfixtures {};

  tissue = callPackage ../development/python-modules/tissue { };

  titlecase = callPackage ../development/python-modules/titlecase { };

  tracing = callPackage ../development/python-modules/tracing { };

  translationstring = callPackage ../development/python-modules/translationstring { };

  ttystatus = callPackage ../development/python-modules/ttystatus { };

  larch = callPackage ../development/python-modules/larch { };

  websocket_client = callPackage ../development/python-modules/websockets_client { };

  webhelpers = callPackage ../development/python-modules/webhelpers { };

  whichcraft = callPackage ../development/python-modules/whichcraft { };

  whisper = callPackage ../development/python-modules/whisper { };

  worldengine = callPackage ../development/python-modules/worldengine { };

  carbon = callPackage ../development/python-modules/carbon { };

  ujson = callPackage ../development/python-modules/ujson { };

  unidecode = callPackage ../development/python-modules/unidecode {};

  pyusb = callPackage ../development/python-modules/pyusb { libusb1 = pkgs.libusb1; };

  BlinkStick = callPackage ../development/python-modules/blinkstick { };

  usbtmc = callPackage ../development/python-modules/usbtmc {};

  txgithub = callPackage ../development/python-modules/txgithub { };

  txrequests = callPackage ../development/python-modules/txrequests { };

  txamqp = callPackage ../development/python-modules/txamqp { };

  versiontools = callPackage ../development/python-modules/versiontools { };

  veryprettytable = callPackage ../development/python-modules/veryprettytable { };

  graphite-web = callPackage ../development/python-modules/graphite-web { };

  graphite_api = callPackage ../development/python-modules/graphite-api { };

  graphite_beacon = callPackage ../development/python-modules/graphite_beacon { };

  influxgraph = callPackage ../development/python-modules/influxgraph { };

  graphitepager = callPackage ../development/python-modules/graphitepager { };

  pyspotify = callPackage ../development/python-modules/pyspotify { };

  pykka = callPackage ../development/python-modules/pykka { };

  ws4py = callPackage ../development/python-modules/ws4py {};

  gdata = callPackage ../development/python-modules/gdata { };

  IMAPClient = callPackage ../development/python-modules/imapclient { };

  Logbook = callPackage ../development/python-modules/Logbook { };

  libversion = callPackage ../development/python-modules/libversion {
    inherit (pkgs) libversion;
  };

  libvirt = callPackage ../development/python-modules/libvirt {
    inherit (pkgs) libvirt;
  };

  rpdb = callPackage ../development/python-modules/rpdb { };

  grequests = callPackage ../development/python-modules/grequests { };

  first = callPackage ../development/python-modules/first {};

  flaskbabel = callPackage ../development/python-modules/flaskbabel { };

  speaklater = callPackage ../development/python-modules/speaklater { };

  speedtest-cli = callPackage ../development/python-modules/speedtest-cli { };

  pushbullet = callPackage ../development/python-modules/pushbullet { };

  power = callPackage ../development/python-modules/power { };

  # added 2018-05-23, can be removed once 18.09 is branched off
  udiskie = throw "pythonPackages.udiskie has been replaced by udiskie";

  pythonefl = callPackage ../development/python-modules/python-efl { };

  tlsh = callPackage ../development/python-modules/tlsh { };

  toposort = callPackage ../development/python-modules/toposort { };

  snapperGUI = callPackage ../development/python-modules/snappergui { };

  uncertainties = callPackage ../development/python-modules/uncertainties { };

  funcy = callPackage ../development/python-modules/funcy { };

  vxi11 = callPackage ../development/python-modules/vxi11 { };

  svg2tikz = callPackage ../development/python-modules/svg2tikz { };

  WSGIProxy = callPackage ../development/python-modules/wsgiproxy { };

  blist = callPackage ../development/python-modules/blist { };

  canonicaljson = callPackage ../development/python-modules/canonicaljson { };

  daemonize = callPackage ../development/python-modules/daemonize { };

  pydenticon = callPackage ../development/python-modules/pydenticon { };

  pynac = callPackage ../development/python-modules/pynac { };

  pybindgen = callPackage ../development/python-modules/pybindgen {};

  pygccxml = callPackage ../development/python-modules/pygccxml {};

  pymacaroons-pynacl = callPackage ../development/python-modules/pymacaroons-pynacl { };

  pynacl = callPackage ../development/python-modules/pynacl { };

  service-identity = callPackage ../development/python-modules/service_identity { };

  signedjson = callPackage ../development/python-modules/signedjson { };

  unpaddedbase64 = callPackage ../development/python-modules/unpaddedbase64 { };

  thumbor = callPackage ../development/python-modules/thumbor { };

  thumborPexif = callPackage ../development/python-modules/thumborpexif { };

  pync = callPackage ../development/python-modules/pync { };

  weboob = callPackage ../development/python-modules/weboob { };

  datadiff = callPackage ../development/python-modules/datadiff { };

  termcolor = callPackage ../development/python-modules/termcolor { };

  html2text = callPackage ../development/python-modules/html2text { };

  pychart = callPackage ../development/python-modules/pychart {};

  parsimonious = callPackage ../development/python-modules/parsimonious { };

  networkx = callPackage ../development/python-modules/networkx { };

  ofxclient = callPackage ../development/python-modules/ofxclient {};

  ofxhome = callPackage ../development/python-modules/ofxhome { };

  ofxparse = callPackage ../development/python-modules/ofxparse { };

  ofxtools = callPackage ../development/python-modules/ofxtools { };

  basemap = callPackage ../development/python-modules/basemap { };

  dicttoxml = callPackage ../development/python-modules/dicttoxml { };

  markdown2 = callPackage ../development/python-modules/markdown2 { };

  evernote = callPackage ../development/python-modules/evernote { };

  setproctitle = callPackage ../development/python-modules/setproctitle { };

  thrift = callPackage ../development/python-modules/thrift { };

  geeknote = callPackage ../development/python-modules/geeknote { };

  trollius = callPackage ../development/python-modules/trollius {};

  pynvim = callPackage ../development/python-modules/pynvim {};

  typogrify = callPackage ../development/python-modules/typogrify { };

  smartypants = callPackage ../development/python-modules/smartypants { };

  pypeg2 = callPackage ../development/python-modules/pypeg2 { };

  torchvision = callPackage ../development/python-modules/torchvision { };

  jenkinsapi = callPackage ../development/python-modules/jenkinsapi { };

  jenkins-job-builder = callPackage ../development/python-modules/jenkins-job-builder { };

  dot2tex = callPackage ../development/python-modules/dot2tex { };

  poezio = callPackage ../applications/networking/instant-messengers/poezio { };

  potr = callPackage ../development/python-modules/potr {};

  python-u2flib-host = callPackage ../development/python-modules/python-u2flib-host { };

  pluggy = callPackage ../development/python-modules/pluggy {};

  xcffib = callPackage ../development/python-modules/xcffib {};

  pafy = callPackage ../development/python-modules/pafy { };

  suds = callPackage ../development/python-modules/suds { };

  suds-jurko = callPackage ../development/python-modules/suds-jurko { };

  mailcap-fix = callPackage ../development/python-modules/mailcap-fix { };

  maildir-deduplicate = callPackage ../development/python-modules/maildir-deduplicate { };

  mps-youtube = callPackage ../development/python-modules/mps-youtube { };

  d2to1 = callPackage ../development/python-modules/d2to1 { };

  ovh = callPackage ../development/python-modules/ovh { };

  willow = callPackage ../development/python-modules/willow { };

  importmagic = callPackage ../development/python-modules/importmagic { };

  xgboost = callPackage ../development/python-modules/xgboost {
    xgboost = pkgs.xgboost;
  };

  xkcdpass = callPackage ../development/python-modules/xkcdpass { };

  xlsx2csv = callPackage ../development/python-modules/xlsx2csv { };

  xmpppy = callPackage ../development/python-modules/xmpppy {};

  xstatic = callPackage ../development/python-modules/xstatic {};

  xstatic-bootbox = callPackage ../development/python-modules/xstatic-bootbox {};

  xstatic-bootstrap = callPackage ../development/python-modules/xstatic-bootstrap {};

  xstatic-jquery = callPackage ../development/python-modules/xstatic-jquery {};

  xstatic-jquery-file-upload = callPackage ../development/python-modules/xstatic-jquery-file-upload {};

  xstatic-jquery-ui = callPackage ../development/python-modules/xstatic-jquery-ui {};

  xstatic-pygments = callPackage ../development/python-modules/xstatic-pygments {};

  xvfbwrapper = callPackage ../development/python-modules/xvfbwrapper {
    inherit (pkgs.xorg) xorgserver;
  };

  hidapi = callPackage ../development/python-modules/hidapi {
    inherit (pkgs) udev libusb1;
  };

  mnemonic = callPackage ../development/python-modules/mnemonic { };

  keepkey = callPackage ../development/python-modules/keepkey { };

  libagent = callPackage ../development/python-modules/libagent { };

  ledgerblue = callPackage ../development/python-modules/ledgerblue { };

  ecpy = callPackage ../development/python-modules/ecpy { };

  semver = callPackage ../development/python-modules/semver { };

  ed25519 = callPackage ../development/python-modules/ed25519 { };

  trezor = callPackage ../development/python-modules/trezor { };

  trezor_agent = callPackage ../development/python-modules/trezor_agent { };

  x11_hash = callPackage ../development/python-modules/x11_hash { };

  termstyle = callPackage ../development/python-modules/termstyle { };

  green = callPackage ../development/python-modules/green { };

  topydo = throw "python3Packages.topydo was moved to topydo"; # 2017-09-22

  w3lib = callPackage ../development/python-modules/w3lib { };

  queuelib = callPackage ../development/python-modules/queuelib { };

  scrapy = callPackage ../development/python-modules/scrapy { };

  pandocfilters = callPackage ../development/python-modules/pandocfilters { };

  htmltreediff = callPackage ../development/python-modules/htmltreediff { };

  repeated_test = callPackage ../development/python-modules/repeated_test { };

  Keras = callPackage ../development/python-modules/keras { };

  keras-applications = callPackage ../development/python-modules/keras-applications { };

  keras-preprocessing = callPackage ../development/python-modules/keras-preprocessing { };

  Lasagne = callPackage ../development/python-modules/lasagne { };

  send2trash = callPackage ../development/python-modules/send2trash { };

  sigtools = callPackage ../development/python-modules/sigtools { };

  clize = callPackage ../development/python-modules/clize { };

  zerobin = callPackage ../development/python-modules/zerobin { };

  tensorflow-tensorboard = callPackage ../development/python-modules/tensorflow-tensorboard { };

  tensorflow = disabledIf isPy37 (
    if stdenv.isDarwin
    then callPackage ../development/python-modules/tensorflow/bin.nix { }
    else callPackage ../development/python-modules/tensorflow/bin.nix rec {
      cudaSupport = pkgs.config.cudaSupport or false;
      inherit (pkgs.linuxPackages) nvidia_x11;
      cudatoolkit = pkgs.cudatoolkit_9_0;
      cudnn = pkgs.cudnn_cudatoolkit_9_0;
    });

  tensorflowWithoutCuda = self.tensorflow.override {
    cudaSupport = false;
  };

  tensorflowWithCuda = self.tensorflow.override {
    cudaSupport = true;
  };

  tflearn = callPackage ../development/python-modules/tflearn { };

  simpleai = callPackage ../development/python-modules/simpleai { };

  word2vec = callPackage ../development/python-modules/word2vec { };

  tvdb_api = callPackage ../development/python-modules/tvdb_api { };

  sdnotify = callPackage ../development/python-modules/sdnotify { };

  tvnamer = callPackage ../development/python-modules/tvnamer { };

  threadpool = callPackage ../development/python-modules/threadpool { };

  rocket-errbot = callPackage ../development/python-modules/rocket-errbot {  };

  Yapsy = callPackage ../development/python-modules/yapsy { };

  ansi = callPackage ../development/python-modules/ansi { };

  pygments-markdown-lexer = callPackage ../development/python-modules/pygments-markdown-lexer { };

  telegram = callPackage ../development/python-modules/telegram { };

  python-telegram-bot = callPackage ../development/python-modules/python-telegram-bot { };

  irc = callPackage ../development/python-modules/irc { };

  jaraco_logging = callPackage ../development/python-modules/jaraco_logging { };

  jaraco_text = callPackage ../development/python-modules/jaraco_text { };

  jaraco_collections = callPackage ../development/python-modules/jaraco_collections { };

  jaraco_itertools = callPackage ../development/python-modules/jaraco_itertools { };

  inflect = callPackage ../development/python-modules/inflect { };

  more-itertools = callPackage ../development/python-modules/more-itertools { };

  jaraco_functools = callPackage ../development/python-modules/jaraco_functools { };

  jaraco_classes = callPackage ../development/python-modules/jaraco_classes { };

  jaraco_stream = callPackage ../development/python-modules/jaraco_stream { };

  tempora= callPackage ../development/python-modules/tempora { };

  hypchat = callPackage ../development/python-modules/hypchat { };

  pivy = callPackage ../development/python-modules/pivy { };

  smugpy = callPackage ../development/python-modules/smugpy { };

  smugline = callPackage ../development/python-modules/smugline { };

  txaio = callPackage ../development/python-modules/txaio { };

  ramlfications = callPackage ../development/python-modules/ramlfications { };

  yapf = callPackage ../development/python-modules/yapf { };

  black = callPackage ../development/python-modules/black { };

  bjoern = callPackage ../development/python-modules/bjoern { };

  autobahn = callPackage ../development/python-modules/autobahn { };

  jsonref = callPackage ../development/python-modules/jsonref { };

  whoosh = callPackage ../development/python-modules/whoosh { };

  packet-python = callPackage ../development/python-modules/packet-python { };

  pwntools = callPackage ../development/python-modules/pwntools { };

  ROPGadget = callPackage ../development/python-modules/ROPGadget { };

  # We need "normal" libxml2 and not the python package by the same name.
  pywbem = callPackage ../development/python-modules/pywbem { libxml2 = pkgs.libxml2; };

  unicorn = callPackage ../development/python-modules/unicorn { };

  intervaltree = callPackage ../development/python-modules/intervaltree { };

  packaging = callPackage ../development/python-modules/packaging { };

  preggy = callPackage ../development/python-modules/preggy { };

  pytoml = callPackage ../development/python-modules/pytoml { };

  pypandoc = callPackage ../development/python-modules/pypandoc { };

  yamllint = callPackage ../development/python-modules/yamllint { };

  yanc = callPackage ../development/python-modules/yanc { };

  yarl = callPackage ../development/python-modules/yarl { };

  suseapi = callPackage ../development/python-modules/suseapi { };

  typed-ast = callPackage ../development/python-modules/typed-ast { };

  stripe = callPackage ../development/python-modules/stripe { };

  twilio = callPackage ../development/python-modules/twilio { };

  uranium = callPackage ../development/python-modules/uranium { };

  uuid = callPackage ../development/python-modules/uuid { };

  versioneer = callPackage ../development/python-modules/versioneer { };

  vine = callPackage ../development/python-modules/vine { };

  visitor = callPackage ../development/python-modules/visitor { };

  whitenoise = callPackage ../development/python-modules/whitenoise { };

  XlsxWriter = callPackage ../development/python-modules/XlsxWriter { };

  yowsup = callPackage ../development/python-modules/yowsup { };

  wptserve = callPackage ../development/python-modules/wptserve { };

  yenc = callPackage ../development/python-modules/yenc { };

  zeep = callPackage ../development/python-modules/zeep { };

  zeitgeist = disabledIf isPy3k
    (toPythonModule (pkgs.zeitgeist.override{python2Packages=self;})).py;

  zeroconf = callPackage ../development/python-modules/zeroconf { };

  zipfile36 = callPackage ../development/python-modules/zipfile36 { };

  todoist = callPackage ../development/python-modules/todoist { };

  zstd = callPackage ../development/python-modules/zstd {
    inherit (pkgs) zstd pkgconfig;
  };

  zxcvbn-python = callPackage ../development/python-modules/zxcvbn-python { };

  incremental = callPackage ../development/python-modules/incremental { };

  treq = callPackage ../development/python-modules/treq { };

  snakeviz = callPackage ../development/python-modules/snakeviz { };

  nitpick = callPackage ../applications/version-management/nitpick { };

  pluginbase = callPackage ../development/python-modules/pluginbase { };

  node-semver = callPackage ../development/python-modules/node-semver { };

  distro = callPackage ../development/python-modules/distro { };

  bz2file =  callPackage ../development/python-modules/bz2file { };

  smart_open =  callPackage ../development/python-modules/smart_open { };

  gensim = callPackage  ../development/python-modules/gensim { };

  cymem = callPackage ../development/python-modules/cymem { };

  ftfy = callPackage ../development/python-modules/ftfy { };

  murmurhash = callPackage ../development/python-modules/murmurhash { };

  plac = callPackage ../development/python-modules/plac { };

  preshed = callPackage ../development/python-modules/preshed { };

  backports_weakref = callPackage ../development/python-modules/backports_weakref { };

  thinc = callPackage ../development/python-modules/thinc { };

  yahooweather = callPackage ../development/python-modules/yahooweather { };

  spacy = callPackage ../development/python-modules/spacy { };

  spacy_models = callPackage ../development/python-modules/spacy/models.nix { };

  pyspark = callPackage ../development/python-modules/pyspark { };

  pysensors = callPackage ../development/python-modules/pysensors { };

  sseclient = callPackage ../development/python-modules/sseclient { };

  warrant = callPackage ../development/python-modules/warrant { };

  textacy = callPackage ../development/python-modules/textacy { };

  tldextract = callPackage ../development/python-modules/tldextract { };

  pyemd  = callPackage ../development/python-modules/pyemd { };

  pulp  = callPackage ../development/python-modules/pulp { };

  behave = callPackage ../development/python-modules/behave { };

  pyhamcrest = callPackage ../development/python-modules/pyhamcrest { };

  parse = callPackage ../development/python-modules/parse { };

  parse-type = callPackage ../development/python-modules/parse-type { };

  ephem = callPackage ../development/python-modules/ephem { };

  voluptuous = callPackage ../development/python-modules/voluptuous { };

  voluptuous-serialize = callPackage ../development/python-modules/voluptuous-serialize { };

  pysigset = callPackage ../development/python-modules/pysigset { };

  us = callPackage ../development/python-modules/us { };

  wsproto = callPackage ../development/python-modules/wsproto { };

  h11 = callPackage ../development/python-modules/h11 { };

  python-docx = callPackage ../development/python-modules/python-docx { };

  aiohue = callPackage ../development/python-modules/aiohue { };

  PyMVGLive = callPackage ../development/python-modules/pymvglive { };

  coinmarketcap = callPackage ../development/python-modules/coinmarketcap { };

  pyowm = callPackage ../development/python-modules/pyowm { };

  prometheus_client = callPackage ../development/python-modules/prometheus_client { };

  pysdl2 = callPackage ../development/python-modules/pysdl2 { };

  pyogg = callPackage ../development/python-modules/pyogg { };

  rubymarshal = callPackage ../development/python-modules/rubymarshal { };

  radio_beam = callPackage ../development/python-modules/radio_beam { };

  spectral-cube = callPackage ../development/python-modules/spectral-cube { };

  astunparse = callPackage ../development/python-modules/astunparse { };

  gast = callPackage ../development/python-modules/gast { };

  IBMQuantumExperience = callPackage ../development/python-modules/ibmquantumexperience { };

  qiskit = callPackage ../development/python-modules/qiskit { };

  qasm2image = callPackage ../development/python-modules/qasm2image { };

  simpy = callPackage ../development/python-modules/simpy { };

  x256 = callPackage ../development/python-modules/x256 { };

  yattag = callPackage ../development/python-modules/yattag { };

  z3 = (toPythonModule (pkgs.z3.override {
    inherit python;
  })).python;

  rfc7464 = callPackage ../development/python-modules/rfc7464 { };

  foundationdb51 = callPackage ../servers/foundationdb/python.nix { foundationdb = pkgs.foundationdb51; };
  foundationdb52 = callPackage ../servers/foundationdb/python.nix { foundationdb = pkgs.foundationdb52; };
  foundationdb60 = callPackage ../servers/foundationdb/python.nix { foundationdb = pkgs.foundationdb60; };

  libtorrentRasterbar = (toPythonModule (pkgs.libtorrentRasterbar.override {
    inherit python;
  })).python;

  libiio = (toPythonModule (pkgs.libiio.override {
    inherit python;
  })).python;

  scour = callPackage ../development/python-modules/scour { };

  pymssql = callPackage ../development/python-modules/pymssql { };

  nanoleaf = callPackage ../development/python-modules/nanoleaf { };

  importlib-metadata = callPackage ../development/python-modules/importlib-metadata {};

  importlib-resources = callPackage ../development/python-modules/importlib-resources {};

  srptools = callPackage ../development/python-modules/srptools { };

  curve25519-donna = callPackage ../development/python-modules/curve25519-donna { };

  pyatv = callPackage ../development/python-modules/pyatv { };

  pybotvac = callPackage ../development/python-modules/pybotvac { };

  pytado = callPackage ../development/python-modules/pytado { };

  casttube = callPackage ../development/python-modules/casttube { };

});

in fix' (extends overrides packages)
