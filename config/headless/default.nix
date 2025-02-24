{ inputs, config, pkgs, lib, ... }: let

    modules = builtins.map (module: import module {inherit inputs config pkgs lib;})([
        #./optional/kmscon.nix
    ] 
    ++ (lib.lsFiles ./core)
    );

in lib.recursiveMerge modules
