{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
lib.mkMerge [
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
  }
  (lib.mkIf config.nix.monitored.enable {
    nix.monitored = {
      package = pkgs.nix-monitored.override {
        nix = pkgs.lixPackageSets.stable.lix;
      };
    };
  })
  (lib.mkIf (!config.nix.monitored.enable) { nix.package = pkgs.lixPackageSets.stable.lix; })
]
