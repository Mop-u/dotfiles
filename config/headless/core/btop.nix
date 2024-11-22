{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        programs.btop = {
            enable = true;
            catppuccin.enable = true;
        };
    };
}
