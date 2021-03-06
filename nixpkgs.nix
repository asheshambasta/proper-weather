# import a pinned nixpkgs for use in this package.
let
  # this nixutils version packs a constant nix expression that contains 
  # commonly used functions that do not depend on pkgs for their eval.
  funcs = import "${utilsSrc}/utils/constant.nix";
  # src for our nixutils 
  utilsSrc = builtins.fetchGit {
    url = "ssh://git@github.com/centralapp/ca-nixutils.git";
    ref = "asheshambasta/feature/overlays-with-extend";
    rev = "f3cc1198044bd987b53b8406bdd69af4289afdc3";
  };
  # This is 'pinned' but it still varies depending on the HEAD of this channel. 
  # If this proves to be a problem, we can pin to specific hashes. However, that is overkill at this 
  # point and a need is yet to arise. 
  nixpkgs = import (funcs.fetchNixChannel "nixos-20.03");
in { inherit utilsSrc funcs nixpkgs; }
