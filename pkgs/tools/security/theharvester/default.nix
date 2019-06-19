{ stdenv, fetchFromGitHub, makeWrapper, python3Packages }:

stdenv.mkDerivation rec {
  pname = "theHarvester";
  version = "3.0.6";

  src = fetchFromGitHub {
    owner = "laramies";
    repo = pname;
    rev = version;
    sha256 = "0f33a7sfb5ih21yp1wspb03fxsls1m14yizgrw0srfirm2a6aa0c";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [ requests beautifulsoup4 plotly ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname} $out/bin

    mv * $out/share/${pname}/

    makeWrapper $out/share/${pname}/theHarvester.py $out/bin/theharvester \
      --prefix PYTHONPATH : $out/share/${pname}:$PYTHONPATH

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Gather E-mails, subdomains and names from different public sources";
    homepage = "https://github.com/laramies/theHarvester";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ treemo ];
  };
}
