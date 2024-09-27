{ inputs, config, pkgs, lib, target, ... }: let

    #todo: use builtins.readDir to get all add-in modules from a directory
    modules = builtins.map (module: import module {inherit inputs config pkgs lib target;})[
        ./bemenu.nix
        ./coreServices.nix
        ./discord.nix
        ./dunst.nix
        ./foot.nix
        ./goxlr.nix
        ./hyprland.nix
        ./hyprswitch.nix
        ./misc.nix
        ./sublime4.nix
        ./vesktop.nix
        ./waybar.nix
    ];

in target.lib.recursiveMerge modules
