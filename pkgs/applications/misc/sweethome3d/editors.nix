{ stdenv, fetchurl, fetchcvs, unzip, makeWrapper, makeDesktopItem, jdk, jre, ant
, gtk3, gsettings-desktop-schemas, p7zip, sweethome3dApp }:

let

  sweetExec = with stdenv.lib;
    m: "sweethome3d-"
    + removeSuffix "libraryeditor" (toLower m)
    + "-editor";
  sweetName = m: v: sweetExec m + "-" + v;

  getDesktopFileName = drvName: (builtins.parseDrvName drvName).name;

  mkEditorProject =
  { name, module, version, src, license, description, desktopName }:

  stdenv.mkDerivation rec {
    application = sweethome3dApp;
    inherit name module version src description;
    exec = sweetExec module;
    editorItem = makeDesktopItem {
      inherit exec desktopName;
      name = getDesktopFileName name;
      comment =  description;
      genericName = "Computer Aided (Interior) Design";
      categories = "Application;Graphics;2DGraphics;3DGraphics;";
    };

    buildInputs = [ ant jre jdk makeWrapper gtk3 gsettings-desktop-schemas ];

    nativeBuildInputs = [ unzip ];

    patchPhase = ''
      # sed -i -e 's,../SweetHome3D,${application.src},g' build.xml
      sed -i -e 's,lib/macosx/java3d-1.6/jogl-all.jar,lib/java3d-1.6/jogl-all.jar,g' build.xml
    '';

    buildPhase = ''
      ant -lib ${application.src}/libtest -lib ${application.src}/lib -lib ${jdk}/lib
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/{java,applications}
      cp ${module}-${version}.jar $out/share/java/.
      cp "${editorItem}/share/applications/"* $out/share/applications
      makeWrapper ${jre}/bin/java $out/bin/$exec \
        --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:${gtk3.out}/share:${gsettings-desktop-schemas}/share:$out/share:$GSETTINGS_SCHEMAS_PATH" \
        --add-flags "-jar $out/share/java/${module}-${version}.jar ${if stdenv.system == "x86_64-linux" then "-d64" else "-d32"}"
    '';

    dontStrip = true;

    meta = {
      homepage = http://www.sweethome3d.com/index.jsp;
      inherit description;
      inherit license;
      maintainers = [ stdenv.lib.maintainers.edwtjo ];
      platforms = stdenv.lib.platforms.linux;
    };

  };

  d2u = stdenv.lib.replaceChars ["."] ["_"];

in {

  textures-editor = mkEditorProject rec {
    version = "1.5";
    module = "TexturesLibraryEditor";
    name = sweetName module version;
    description = "Easily create SH3T files and edit the properties of the texture images it contain";
    license = stdenv.lib.licenses.gpl2Plus;
    src = fetchurl {
      url= "mirror://sourceforge/sweethome3d/${module}-${version}-src.zip";
      sha256 = "0glgcb9as2qa72fwlh35qiddh28mifrimsfjp53xyl2g60rw5yib";
    };
    desktopName = "Sweet Home 3D - Textures Library Editor";
  };

  furniture-editor = mkEditorProject rec {
    version = "1.22";
    module = "FurnitureLibraryEditor";
    name = sweetName module version;
    description = "Quickly create SH3F files and edit the properties of the 3D models it contain";
    license = stdenv.lib.licenses.gpl2;
    src = fetchurl {
      url= "mirror://sourceforge/sweethome3d/${module}-${version}-src.zip";
      sha256 = "0gvvha9n4axpplfjr7n0jy4nx7j746bw9absjyk3f8z5h0wx7r1x";
    };
    desktopName = "Sweet Home 3D - Furniture Library Editor";
  };

}
