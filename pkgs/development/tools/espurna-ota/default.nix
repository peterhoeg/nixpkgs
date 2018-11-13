{ lib, fetchFromGitHub, python3 }:

with python3.pkgs;

buildPythonApplication rec {
  pname   = "espurna-ota";
  version = "1.13.3";

  src = fetchFromGitHub {
    owner  = "xoseperez";
    repo   = "espurna";
    rev    = version;
    sha256 = "1qhxzlyb6idwigblfx3kfapsis79nqabxza7z0hgzaw19l9dk346";
  };

  postPatch = ''
    substituteInPlace code/ota.py \
      --replace espurna/config/hardware.h $out/share/espurna-ota/hardware.h
  '';

  format = "other";

  propagatedBuildInputs = [
    netifaces ordereddict sortedcontainers zeroconf
  ] ++ lib.optional (!isPy3k) six;

  installPhase = ''
    runHook preInstall

    install -Dm755 code/ota.py $out/bin/espurna-ota
    install -Dm644 code/espurna/config/hardware.h $out/share/espurna-ota/hardware.h

    runHook postInstall
  '';

  # no tests
  doCheck = false;

  meta = with lib; {
    description = "Discover and update existing espurna devices on your network";
    homepage = http://tinkerman.cat;
    license = licenses.asl20;
  };
}
