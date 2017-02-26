{ stdenv, lib, fetchurl, makeWrapper, docker-machine-kvm, kubernetes, libvirt, qemu }:

let
  arch = if stdenv.isLinux
         then "linux-amd64"
         else "darwin-amd64";
  checksum = if stdenv.isLinux
             then "0nd614bzk3rx15ywfx6qknqr6zn24b2d8vfgjks29wy2m4w38v88"
             else "08csl2abydzsj1qqs47yldj7pi2x94lxzp71cdaqqlzzv7wb8byi";


# TODO: compile from source

in stdenv.mkDerivation rec {
  pname = "minikube";
  version = "0.17.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://storage.googleapis.com/minikube/releases/v${version}/minikube-${arch}";
    sha256 = "${checksum}";
  };

  phases = [ "installPhase" ];

  buildInputs = [ makeWrapper ];

  binPath = lib.makeBinPath [ docker-machine-kvm kubernetes libvirt qemu ];

  installPhase = ''
    install -Dm755 ${src} $out/bin/${pname}

    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${binPath}
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/kubernetes/minikube;
    description = "A tool that makes it easy to run Kubernetes locally";
    license = licenses.asl20;
    maintainers = with maintainers; [ ebzzry ];
    platforms = with platforms; linux ++ darwin;
  };
}
