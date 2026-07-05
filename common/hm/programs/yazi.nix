{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.yazi = {
    enable = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;
    shellWrapperName = "y";
  };
}
