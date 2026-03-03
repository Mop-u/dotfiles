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
        ./lix.nix
        ./networkMounts.nix
        ./virtualbox.nix
    ];
    
}
