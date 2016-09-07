{ callPackage, plugins ? [] }:

let
  unwrapped = callPackage ./unwrapped.nix { };
  wrapped   = self.callPackage ./wrapper.nix {
    plugins = plugins;
    fcitx   = unwrapped;
  };
in if plugins == []
   then unwrapped
   else wrapped
