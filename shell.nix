{ optimize ? false }:
let
  nixpkgs = import (import ./nix/sources.nix).nixpkgs { };
  release = import ./release.nix { inherit optimize; };
in nixpkgs.haskellPackages.shellFor {
  packages = p: builtins.attrValues release;
  buildInputs = with nixpkgs; [
    inotify-tools
    haskellPackages.cabal-install
    haskellPackages.ghcid
  ];
}
