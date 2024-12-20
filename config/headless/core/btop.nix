{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        catppuccin.btop.enable = true;
        programs.btop = {
            enable = true;
        };
    };
}
