{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./niri.nix
    ./keybinds.nix
  ];
}
