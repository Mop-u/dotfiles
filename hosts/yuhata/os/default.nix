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
        ./gamemode.nix
        ./hardware-configuration.nix
        ./lix.nix
        ./networkMounts.nix
        ./steam.nix
    ];
}
