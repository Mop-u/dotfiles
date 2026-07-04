{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./fusesoc.nix
    ./haskell.nix
    ./helix.nix
    ./verilog.nix
  ];
}
