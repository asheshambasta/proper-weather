let
  sources = import ./nix/sources.nix; 
in 
{ optimize ? false }:
let
  pkgs = import sources.nixpkgs { };
  release = import ./release.nix { inherit optimize; };
in pkgs.haskellPackages.shellFor {
  packages = p: builtins.attrValues release;
  buildInputs = with pkgs; [
    inotify-tools
    haskellPackages.cabal-install
    haskellPackages.ghcid
    haskellPackages.hlint 
  ];
}
