{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    extraPackages = with pkgs; [
      ghc
      haskell-language-server
      fourmolu
    ];
  };
}
