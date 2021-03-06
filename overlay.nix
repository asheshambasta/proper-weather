{ optimize }:
self: super:
let
  sources = import ./nix/sources.nix;
  gitignore = (import sources.gitignore {}).gitignoreSource;
  hlib = super.haskell.lib;
  lib = super.lib;
  maybeOptimize = x: if optimize then x else hlib.disableOptimization x;
  pwOverrides = selfh: superh: {
    xmobar-proper-weather = maybeOptimize
      ((superh.callCabal2nix "xmobar-proper-weather" (gitignore ./.) { }));
  };
in {
  haskellPackages = super.haskellPackages.override (old: {
    overrides =
      lib.composeExtensions (old.overrides or (_: _: { })) pwOverrides;
  });
}
