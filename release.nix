args@{ optimize , nixpkgs ? (import <nixpkgs>) }:
let
  sources = import ./nix/sources.nix;

  overlays = (with sources; [
    (import ./overlay.nix args)
  ]);
  nixpkgs-overlayed = nixpkgs { inherit overlays; };

in { inherit (nixpkgs-overlayed.haskellPackages) xmobar-proper-weather; }
