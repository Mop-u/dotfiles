{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./memory.nix
    ./audio.nix
  ];
}
