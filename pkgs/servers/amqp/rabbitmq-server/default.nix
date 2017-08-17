{ stdenv, fetchFromGitHub, perl, erlang, python, libxml2, libxslt, xmlto
, docbook_xml_dtd_45, docbook_xsl, zip, unzip, rsync
, AppKit, Carbon, Cocoa
}:

let
  version = "3.6.6";

  owner  = "rabbitmq";
  rev = (stdenv.lib.replaceStrings [ "." ] [ "_" ] "rabbitmq_v${version}");

  codegen = stdenv.mkDerivation rec {
    name = "rabbitmq-codegen-${version}";
    src = fetchFromGitHub {
      repo = "rabbitmq-codegen";
      sha256 = "12999bjbjixij36abn9n8wrzjik62wy7iyqgpafzp4zbgkf49258";
      inherit owner rev;
    };
    buildInputs = [ python ];
    installPhase = ''
      mkdir -p $out/bin
      echo "#!${python.interpreter}" > $out/bin/amqp_codegen.py
      cat amqp_codegen.py >> $out/bin/amqp_codegen.py
    '';
  };

  common = stdenv.mkDerivation rec {
    name = "rabbitmq-common-${version}";
    src = fetchFromGitHub {
      repo   = "rabbitmq-common";
      sha256 = "1qdbnvq38kpkz2wq1qfwvnp6a6ldi5xcd9s124dyndpfxhh3nh4l";
      inherit owner rev;
    };
    buildInputs = [ codegen erlang python ];
    preBuild = ''
      mkdir -p deps

      ln -s ${codegen.src}  deps/rabbitmq_codegen
    '';
    installPhase = ''
      mkdir -p $out
      mv ebin $out/
    '';
  };

  ranch = stdenv.mkDerivation rec {
    name = "ranch-${version}";
    version = "0.6.1";
    src = fetchFromGitHub {
      owner  = "rabbitmq";
      repo   = "ranch";
      rev    = version;
      sha256 = "06m9jpjr79vp3q861asc1i6b5in8rcyrgjw0azv6fgnqh8w12kpi";
    };
    buildInputs = [ erlang ];
    installPhase = ''
      mkdir -p $out
      mv ebin $out/
    '';
  };

in stdenv.mkDerivation rec {
  name = "rabbitmq-server-${version}";

  src = fetchFromGitHub {
    repo   = "rabbitmq-server";
    sha256 = "1h3lrar7svajx7ccf6zrn8csr2hlxc8fwnvpx62pndvjw9nzgdm7";
    inherit owner rev;
  };

  buildInputs = [
    erlang libxml2 libxslt zip unzip rsync
    codegen common ranch
  ] ++ stdenv.lib.optionals stdenv.isDarwin [ AppKit Carbon Cocoa ];
  nativeBuildInputs = [
    docbook_xml_dtd_45 docbook_xsl xmlto
    perl python
  ];

  preBuild = ''
    # Fix the "/usr/bin/env" in "calculate-relative".
    patchShebangs .

    export CLI_ESCRIPTS_DIR=$out/bin

    mkdir -p deps

    cp -r ${codegen.src}  deps/rabbitmq_codegen
    cp -r ${common.src}   deps/rabbit_common
    cp -r ${ranch.src}    deps/ranch
    substituteInPlace deps/ranch/Makefile \
      --replace ebin/ $out/ebin/
  '';

  installFlags = "PREFIX=$(out) RMQ_ERLAPP_DIR=$(out)";

  installTargets = "install install-man";

  postInstall = ''
    mkdir -p $out/share/doc/rabbitmq-server
    mv $out/LICEN* $out/share/doc/rabbitmq-server

    echo 'PATH=${erlang}/bin:''${PATH:+:}$PATH' >> $out/sbin/rabbitmq-env
  '';

  meta = with stdenv.lib; {
    description = "An implementation of the AMQP messaging protocol";
    homepage = http://www.rabbitmq.com/;
    platforms = platforms.unix;
  };
}
