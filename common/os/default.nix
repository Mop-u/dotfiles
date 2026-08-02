{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sidonia;
in
{
  imports = [
    ./configuration.nix
    ./lix.nix
    ./niri.nix
    ./programs
    ./services
    ./tweaks
    ./modules
  ];
}
