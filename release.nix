let sources = import ./nix/sources.nix;
in args@{ optimize, nixpkgs ? (import sources.nixpkgs) }:
let

  overlays = [ (import ./overlay.nix args) ];
  nixpkgs-overlayed = nixpkgs { inherit overlays; };

in { inherit (nixpkgs-overlayed.haskellPackages) xmobar-proper-weather; }
