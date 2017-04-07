{ stdenv, lib, fetchFromGitHub, lzma, qemu }:

let
  src = fetchFromGitHub {
    owner  = "kholia";
    repo   = "OSX-KVM";
    rev    = "932b0c0ccaae7f02a91782a63dab599e85ad3511";
    sha256 = "08axgbknjwqc42w38klh6piyi8d3j6yib73hgw5g2ic6d50ql1dz";
  };

  buildPbzx = stdenv.isDarwin;

  pbzx = stdenv.mkDerivation rec {
    name = "pbzx";
    inherit src;
    buildInputs = [ lzma ];
    buildPhase = ''
      cd pbzx-src
      gcc -Wall -o pbzx -I${lzma.dev}/usr/include -L${lzma}/usr/lib -llzma -lxar pbzx.c
    '';
    installPhase = ''
      install -Dm755 pbzx $out/bin
    '';
    meta.broken = !buildPbzx;
  };

in stdenv.mkDerivation rec {

  name = "qemu-osx-${version}";
  version = "1.0.6";

  inherit src;

  patches = [
    # we are forcing bash anyway and the check fails due to -eu
    ./remove_bash_check.patch
  ];

  buildInputs = [] ++ lib.optional stdenv.isDarwin pbzx;

  installPhase = ''
    install -Dm755 *.sh                -t $out/bin
    install -Dm644 enoch*_boot *.plist -t $out/share/qemu-osx
    install -Dm644 *.md *.txt          -t $out/share/qemu-osx/doc

    ${lib.optionalString buildPbzx ''
      cp ${pbzx}/bin/pbzx $out/bin
    ''}

    for f in $out/bin/boot*.sh ; do
      substituteInPlace $f \
        --replace qemu-system-x86_64  {qemu}/bin/qemu-system-x86_64 \
        --replace ./enoch_            $out/share/qemu-osx/enoch_ \
        --replace e1000-82545em,      vmxnet3,
    done

    substituteInPlace $out/bin/create_install_iso.sh \
      --replace '$script_dir/pbzx'          "$out/bin/pbzx" \
      --replace '$script_dir/org.chameleon' "$out/share/qemu-osx/org.chameleon"

    # fixupPhase fixes the bash path, but we want -eu as well
    for f in $out/bin/*.sh ; do
      substituteInPlace $f --replace /bin/bash '${stdenv.shell} -eu'
    done
  '';

  meta = with stdenv.lib; {
    description = "Run OSX under QEMU/KVM";
    longDescription = ''
      A set of scripts that allows you to create and boot an .iso file of macOS under QEMU

      You will need an actual Mac on which to run the .iso generation part.

      Booting the generated image can be done under !macOS.
    '';
    homepage = http://github.com/kholia/OSX-KVM;
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = platforms.unix;
  };
}
