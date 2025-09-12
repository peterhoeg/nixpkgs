{
  stdenv,
  fetchurl,
  fetchzip,
  lib,
  makeWrapper,
  unzip,
  glib,
  gtk2,
  gtk3,
  libXtst,
  coreutils,
  makeDesktopItem,
  gnugrep,
  zulu21,
  preferGtk3 ? true,
}:

let
  rev = 3755;
  # for the recommended java version, have a look in https://github.com/mguessan/davmail/blob/master/build.xml in the
  # "download-jre" target
  jre' = zulu21.override { enableJavaFX = true; };
  gtk' = if preferGtk3 then gtk3 else gtk2;

  binPath = lib.makeBinPath [
    jre'
    coreutils
    gnugrep
  ];

  libPath = lib.makeLibraryPath [
    glib
    gtk'
    libXtst
  ];

  desktop = makeDesktopItem {
    name = "DavMail";
    desktopName = "DavMail POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange Gateway";
    icon = "davmail";
    exec = "@out@/bin/davmail";
    categories = [
      "GTK"
      "GNOME"
      "Network"
      "Email"
    ];
    keywords = [
      "pop"
      "imap"
      "smtp"
      "exchange"
      "owa"
      "outlook"
    ];
    startupWMClass = "davmail-DavGateway";
  };

  # the icon hasn't changed in years, but we just need a stable URL so pin it at version 6.4.0
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/mguessan/davmail/6.4.0/src/icon/davmail.png";
    hash = "sha256-kYi6Rs9Lxzmj1g8VVlOljiCo4CwJ/5pWPpZctDjlcsE=";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "davmail";
  version = "6.4.0";

  src = fetchzip {
    url = "mirror://sourceforge/davmail/${finalAttrs.finalPackage.version}/davmail-${finalAttrs.finalPackage.version}-${toString rev}.zip";
    hash = "sha256-cGuAxSIkhkcpRXlv5f3utH/1zZ1aYbLQN/OLuN80JdM=";
    stripRoot = false;
  };

  postPatch = ''
    sed -i -e '/^JAVA_OPTS/d' davmail
  '';

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    dir=$out/opt/davmail

    mkdir -p $dir
    cp -vR ./* $dir
    makeWrapper $dir/davmail $out/bin/davmail \
      --set-default JAVA_OPTS "-Xmx512M -Dsun.net.inetaddr.ttl=60 -Djdk.gtk.version=${lib.versions.major gtk'.version}" \
      --prefix PATH : ${binPath} \
      --prefix LD_LIBRARY_PATH : ${libPath}

    install -Dm444 ${icon} $out/share/icons/hicolor/128x128/apps/davmail.png
    install -Dm444 ${desktop}/share/applications/* $out/share/applications/davmail.desktop
    substituteInPlace $out/share/applications/davmail.desktop \
      --subst-var out

    runHook postInstall
  '';

  meta = {
    description = "Present a Microsoft Exchange server as local CALDAV, IMAP and SMTP servers";
    homepage = "https://davmail.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "davmail";
    inherit (jre'.meta) platforms;
  };
})
