{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./compositorOverrides.nix
    ./keybinds.nix
    ./noctalia.nix
  ];
}
