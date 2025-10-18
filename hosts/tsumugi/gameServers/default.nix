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
        inputs.steam-servers.nixosModules.default
        ./minecraft.nix
        ./cobblemon.nix
        ./palworld.nix
    ];
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.steam-servers.datadir = "/mnt/gameservers/steam";

    services.minecraft-servers = {
        enable = true;
        eula = true;
        dataDir = "/srv/minecraft"; # /srv/minecraft/paper
        runDir = "/run/minecraft"; # tmux -S /run/minecraft/paper.sock attach
    };
}
