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
    ./programs
    ./services
    ./tweaks
    ./configuration.nix
    ./niri.nix
  ];
}
