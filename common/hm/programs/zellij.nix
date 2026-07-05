{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zellij = {
    enable = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;
  };
}
