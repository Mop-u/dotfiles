{inputs, config, pkgs, lib, target, ... }:
{

    home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "backup";
    };

    home-manager.users.${target.userName} = {

        home = {
            username = target.userName;
            homeDirectory = "/home/${target.userName}";
            stateVersion = target.stateVer;
        };

        catppuccin = {
            enable = true;
            accent = target.style.catppuccin.accent;
            flavor = target.style.catppuccin.flavor;
            pointerCursor = {
                enable = true;
                accent = target.style.catppuccin.accent;
                flavor = target.style.catppuccin.flavor;
            };
        };
    };
}