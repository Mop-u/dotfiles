{
    osConfig,
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        ./home.nix
        ./monitors.nix
    ];
    
}
