{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [
      25565 # minecraft
    ];
    allowedUDPPorts = [
      8211 # palworld
    ];
  };
}
