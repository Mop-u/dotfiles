{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./coreServices.nix
    ./displayManager.nix
    ./distributedBuilds.nix
    ./vr.nix
  ];
}
