{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
  # nix.package = pkgs.lixPackageSets.stable.lix;
  nix.monitored = {
    enable = true;
    package = pkgs.nix-monitored.override {
      nix = pkgs.lixPackageSets.stable.lix;
    };
  };
}
