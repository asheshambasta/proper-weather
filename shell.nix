{ optimize ? false, nixpkgs ? (import <nixpkgs>) }:
let
  pkgs = nixpkgs { };
  release = import ./release.nix { inherit optimize; };
in pkgs.haskellPackages.shellFor {
  packages = p: builtins.attrValues release;
  buildInputs = with pkgs; [
    inotify-tools
    haskellPackages.cabal-install
    haskellPackages.ghcid
  ];
}
