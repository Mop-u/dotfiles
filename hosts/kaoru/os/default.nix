{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./networkMounts.nix
    ./virtualbox.nix
  ];

}
