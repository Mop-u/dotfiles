{ inputs, config, pkgs, lib, target, ... }: let

    modules = builtins.map (module: import module {inherit inputs config pkgs lib target;})([
        ./optional/kmscon.nix
    ] ++ (target.lib.lsFiles ./core));

in target.lib.recursiveMerge modules
