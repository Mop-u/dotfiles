{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  services.steamcmd-servers.palworld = {
    enable = true;
    preset = "palworld";
  };
}
