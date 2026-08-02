{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./vr.nix
    ./distributedBuilds.nix
    ./netbird.nix
  ];
}
