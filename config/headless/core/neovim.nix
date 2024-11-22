{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        programs.neovim = {
            enable = true;
            defaultEditor = true;
            catppuccin.enable = true;
        };
    };
}
