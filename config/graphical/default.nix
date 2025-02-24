{ inputs, config, pkgs, lib, ... }: let
    cfg = config.sidonia;
    modules = builtins.map (module: import module {inherit inputs config pkgs lib;})([
        ./optional/vesktop.nix
        ./optional/discord.nix
        ./optional/goxlr.nix
        ./optional/sublime4.nix
    ] ++ (lib.lsFiles ./core));

in lib.mkIf (!cfg.graphics.headless) (lib.recursiveMerge modules)
