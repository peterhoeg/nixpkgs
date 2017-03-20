{ stdenv, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  name    = "do-agent-${version}";
  version = "0.4.10";

  goPackagePath = "github.com/digitalocean/do-agent";
  # subPackages   = [ "agent" ];

  src = fetchFromGitHub {
    owner  = "digitalocean";
    repo   = "do-agent";
    rev    = "v${version}";
    sha256 = "15qvypbd693ryn00gslr0nprzyhiv230lirnqq16hg884wph1ydc";
  };

  meta = with stdenv.lib; {
    description = "DigitalOcean droplet monitoring agent";
    homepage    = https://github.com/digitalocean/do-agent;
    license     = licenses.asl20;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
