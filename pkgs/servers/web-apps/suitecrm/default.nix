{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "suitecrm-${version}";
  version = "7.10.10";

  src = fetchFromGitHub {
    owner  = "salesagility";
    repo   = "SuiteCRM";
    rev    = "v${version}";
    sha256 = "1acjn7ikm7ymlgp94h2kjnwcchwagdhrkb58klalypwvzzrjxcka";
  };

  installPhase = ''
    runHook preInstall

    dir=$out/share/suitecrm
    mkdir -p $dir
    cp -ra * $dir
    find $dir -type f -exec chmod 0644 {} +

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Open Source CRM for the world";
    homepage = https://suitecrm.com;
    license = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
