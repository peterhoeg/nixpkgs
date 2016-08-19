{ stdenv, lib, fetchurl, makeWrapper, patchelf
, gettext, icu, curl, libunwind, libuuid, openssl, zlib, pkgs }:

stdenv.mkDerivation rec {
  name = "dotnet-${version}";
  version = "1.0.0.preview2";

  src = fetchurl {
    url = "https://go.microsoft.com/fwlink/?LinkID=809130";
    sha256 = "1vb39id8fi9h8al1ghlzjs5cfbwrahfmq38vd4bpvhcjpjvylk10";
  };

  nativeBuildInputs = [ makeWrapper patchelf ];

  libPath = with pkgs; lib.makeLibraryPath [
    stdenv.cc.cc.lib
    gettext
    icu
    curl
    openssl
    libunwind
    libuuid
    zlib
  ];

  unpackCmd = "tar xf $curSrc";
  sourceRoot = "./.";

  dontBuild = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/bin $out/opt/dotnet

    mv * $out/opt/dotnet
    ln -s $out/opt/dotnet/dotnet $out/bin/dotnet

    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "${libPath}" \
      $out/opt/dotnet/dotnet

    # we MUST use -n1 to ensure patchelf is run once per .so
    find $out/opt/dotnet -name '*.so' -print0 | xargs -0 -n1 patchelf \
      --set-rpath "${libPath}"

    # until this is empty, it will not work
    find $out -name '*.so' | xargs -I {} ldd {} | grep found
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/dotnet";
    description = ".NET Framework";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
