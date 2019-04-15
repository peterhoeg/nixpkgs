{ stdenv, fetchFromGitHub, makeWrapper, lib
, dnsutils, coreutils, openssl, nettools, utillinux, procps }:

let
  binPath = lib.makeBinPath [
    coreutils # for pwd and printf
    dnsutils  # for dig
    nettools  # for hostname
    openssl   # for openssl
    procps    # for ps
    utillinux # for hexdump
  ];

in stdenv.mkDerivation rec {
  name = "testssl.sh-${version}";
  version = "2.9.5-7";

  src = fetchFromGitHub {
    owner = "drwetter";
    repo = "testssl.sh";
    rev = "v${version}";
    sha256 = "02xp0yi53xf6jw6v633zs2ws2iyyvq3mlkimg0cv3zvj7nw9x5wr";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace testssl.sh \
      --replace /bin/pwd                       pwd \
      --replace 'TESTSSL_INSTALL_DIR:-""'      TESTSSL_INSTALL_DIR:-\"$out\" \
      --replace 'PROG_NAME="$(basename "$0")"' PROG_NAME="testssl.sh"
  '';

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin testssl.sh

    wrapProgram $out/bin/testssl.sh \
      --prefix PATH ':' ${binPath}

    cp -r etc $out

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "CLI tool to check a server's TLS/SSL capabilities";
    longDescription = ''
      CLI tool which checks a server's service on any port for the support of
      TLS/SSL ciphers, protocols as well as recent cryptographic flaws and more.
    '';
    homepage = https://testssl.sh/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ etu ];
  };
}
