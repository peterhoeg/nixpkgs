{ stdenv, symlinkJoin, fcitx, fcitx-configtool, makeWrapper, plugins }:

symlinkJoin {
  name = "fcitx-with-plugins-${fcitx.version}";

  paths = [ fcitx fcitx-configtool fcitx-qt5 ] ++ plugins;

  buildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/fcitx \
      --set FCITXDIR "$out/"
  '';
}
