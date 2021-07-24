{ lib, ruby, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "oxidized-script";
  gemdir = ./.;

  inherit ruby;

  exes = [ "oxidized-script" ];

  passthru.updateScript = bundlerUpdateScript "oxidized-script";

  meta = with lib; {
    description = "CLI and Library to interface with network devices in Oxidized";
    homepage    = "https://github.com/ytti/oxidized";
    license     = licenses.asl20;
    maintainers = with maintainers; [ willibutz nicknovitski ];
    platforms   = platforms.linux;
  };
}
