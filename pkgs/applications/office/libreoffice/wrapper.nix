{ libreoffice, runCommand, bash }:

(runCommand libreoffice.name {
  inherit (libreoffice) jdk VCL_PLUGIN;
  inherit libreoffice bash;
} ''
  mkdir -p "$out/bin"
  ln -s "${libreoffice}/share" "$out/share"
  substituteAll "${./wrapper.sh}" "$out/bin/soffice"
  chmod a+x "$out/bin/soffice"

  for i in $(ls "${libreoffice}/bin/"); do
    test "$i" = "soffice" || ln -s soffice "$out/bin/$(basename "$i")"
  done
'') // {
  inherit libreoffice;
  meta = libreoffice.meta;
}
