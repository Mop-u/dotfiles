{ inputs, config, pkgs, lib, target, ... }: let

    modules = builtins.map (module: import module {inherit inputs config pkgs lib target;})([
        ./optional/vesktop.nix
        ./optional/discord.nix
        ./optional/goxlr.nix
        ./optional/sublime4.nix
    ] ++ (target.lib.lsFiles ./core));

in target.lib.recursiveMerge modules
