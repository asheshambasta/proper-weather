args@{ optimize }:
let
  sources = import ./nix/sources.nix;

  overlays = (with sources; [
    (import ./overlay.nix args)
  ]);
  nixpkgs-overlayed = import sources.nixpkgs { inherit overlays; };

in { inherit (nixpkgs-overlayed.haskellPackages) xmobar-proper-weather; }
