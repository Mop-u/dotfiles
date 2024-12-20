{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        catppuccin.nvim.enable = true;
        programs.neovim = {
            enable = true;
            defaultEditor = true;
        };
    };
}
