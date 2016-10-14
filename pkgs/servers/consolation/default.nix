{ stdenv, fetchgit, autoconf, automake, autoreconfHook, pkgconfig, help2man
, libevdev, libinput }:

let
  desc = "copy-paste for the Linux console";

  service = writeText ''
    [Unit]
    Description = ${desc}

    [Service]
    Type = simple
    ExecStart = $out/bin/consolation
    PrivateNetwork = yes
    PrivateTmp = yes
    MaxTasks = 64
    ProtectHome = yes
    ProtectSystem = full
  '';

in stdenv.mkDerivation rec {
  name = "consolation-${version}";
  version = "0.0.2";

  src = fetchgit {
    url = https://alioth.debian.org/anonscm/git/consolation/consolation.git;
    rev = "846e608ab586d0081bb88e282b3a84b639e0cafb";
    sha256 = "0x21xh941qaf7545c9w8dhbmnbgv2zbjd0z9lyh3v7skpld4zz7b";
  };

  nativeBuildInputs = [ autoconf automake autoreconfHook pkgconfig libevdev libinput ];
  buildInputs = [ help2man ];

  postInstall = ''
    mkdir -p $out/etc/systemd/system
    cp ${service} $out/etc/systemd/system/consolation.service
  '';

  meta = with stdenv.lib; {
    homepage = https://alioth.debian.org/projects/consolation;
    description = desc;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
