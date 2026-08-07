{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./bandcampsync.nix
    ./coreServices.nix
    ./displayManager.nix
  ];
}
