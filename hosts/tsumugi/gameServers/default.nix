{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./minecraft.nix
    ./cobblemon.nix
  ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/srv/minecraft"; # /srv/minecraft/paper
    runDir = "/run/minecraft"; # tmux -S /run/minecraft/paper.sock attach
  };
}
