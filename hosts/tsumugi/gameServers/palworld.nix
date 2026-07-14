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
    openFirewall = true;
    preset = "palworld";
  };
}
