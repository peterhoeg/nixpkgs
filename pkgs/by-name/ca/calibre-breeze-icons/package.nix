{ stdenv
, lib
, resholve
, runtimeShell
, coreutils
, librsvg
, optipng
, calibre
, breeze-icons
, darkIconPath ? "${breeze-icons}/share/icons/breeze-dark"
, lightIconPath ? "${breeze-icons}/share/icons/breeze"
, debug ? false
}:

# *Notes*
#
# 1. This technically doesn't have to be breeze and could be any icon theme.
#
# 2. The script will show which icons do not have a mapped breeze icon.
#
# 3. Especially the textures could benefit from being replaced by something more elegant (IMHO)

let
  imagesDir = "share/calibre/resources/images";

  buildScript = resholve.writeScriptBin "build-calibre-breeze-icons"
    {
      interpreter = runtimeShell;
      inputs = [ coreutils librsvg optipng ];
    }
    (builtins.readFile ./build.sh);

in
stdenv.mkDerivation {
  pname = "calibre-breeze-icons";
  inherit (calibre) version;

  buildCommand = ''
    tar --extract -f ${calibre.src} --one-top-level=.

    CALIBRE_RESOURCES_PATH="./${calibre.name}/resources"
    ${lib.optionalString debug ''
      echo CALIBRE_RESOURCES_PATH=$CALIBRE_RESOURCES_PATH
      echo darkIconPath=${darkIconPath}
      echo lightIconPath=${lightIconPath}
    ''}

    ${lib.getExe buildScript} \
      $CALIBRE_RESOURCES_PATH \
      ${darkIconPath} \
      ${lightIconPath} \
      $out/${imagesDir}
  '';

  passthru = { inherit imagesDir; };

  meta = with lib; {
    description = "Breeze icons for calibre";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (calibre.meta) platforms;
  };
}
