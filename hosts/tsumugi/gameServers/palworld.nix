{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.steamcmd-flake.nixosModules.default ];
  services.steamcmd-servers.palworld = {
    enable = true;
    preset = "palworld";
  };
}
