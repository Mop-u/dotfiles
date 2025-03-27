{
    config,
    pkgs,
    inputs,
    lib,
    ...
}:
{
    imports = [
        ./hardware-configuration.nix
        ./arr.nix
        ./iperf.nix
        ./lancache.nix
        ./minecraft.nix
        ./networkMounts.nix
        ./openssh.nix
        ./reverseProxy.nix
        ./ups.nix
    ];
    sidonia = {
        hostName = "tsumugi";
        userName = "shiraui";
        stateVer = "24.05";
        style.catppuccin.flavor = "macchiato";
        style.catppuccin.accent = "teal";
        services.kmscon.enable = true;
    };
}
