{ stdenv, fetchFromGitHub, perl
, erlang, pythonPackages, libxml2, libxslt, zip, unzip, rsync
, docbook_xml_dtd_45, docbook_xsl, xmlto
, AppKit ? null, Carbon ? null, Cocoa ? null
}:

let
  version = "3.6.6";
  owner = "rabbitmq";
  rev    = (stdenv.lib.replaceStrings [ "." ] [ "_" ] "rabbitmq_v${version}");

  rabbitmq-codegen = fetchFromGitHub {
    repo = "rabbitmq-codegen";
    sha256 = "12999bjbjixij36abn9n8wrzjik62wy7iyqgpafzp4zbgkf49258";
    inherit owner rev;
  };

  rabbitmq-common = fetchFromGitHub {
    repo = "rabbitmq-common";
    sha256 = "1qdbnvq38kpkz2wq1qfwvnp6a6ldi5xcd9s124dyndpfxhh3nh4l";
    inherit owner rev;
  };

in stdenv.mkDerivation rec {
  name = "rabbitmq-server-${version}";
  version = "3.6.6";

  src = fetchFromGitHub {
    owner  = "rabbitmq";
    repo   = "rabbitmq-server";
    # sha256 = "174pvv0982wyll5aqc8y856dy638g1sk39xb3iwxxxfy1sb45kpz";
    sha256 = "1h3lrar7svajx7ccf6zrn8csr2hlxc8fwnvpx62pndvjw9nzgdm7";
    inherit rev;
  };

  buildInputs = [
    # rabbitmq-common
    erlang pythonPackages.python libxml2 libxslt zip unzip rsync
  ] ++ stdenv.lib.optionals stdenv.isDarwin [ AppKit Carbon Cocoa ];

  nativeBuildInputs = [
    docbook_xml_dtd_45 docbook_xsl perl xmlto
  ];

  enableParallelBuilding = true;

  prePatch = ''
    mkdir -p deps
    rm -rf deps/rabbitmq_{codegen,common}
    ln -s ${rabbitmq-codegen} deps/rabbitmq_codegen
    ln -s ${rabbitmq-common}  deps/rabbitmq_common
    # Fix the "/usr/bin/env" in "calculate-relative".
    patchShebangs .

    ls -la deps/
  '';

  makeTargets = [ "all" ];

  installFlags = [
    "PREFIX=$(out)"
    "RMQ_ERLAPP_DIR=$(out)"
  ];

  installTargets = "install install-man";

  postInstall = ''
    echo 'PATH=${stdenv.lib.makeBinPath [ erlang ]}:''${PATH:+:}$PATH' >> $out/sbin/rabbitmq-env
  '';

  meta = with stdenv.lib; {
    homepage = http://www.rabbitmq.com/;
    description = "An implementation of the AMQP messaging protocol";
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
