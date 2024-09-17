{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        services.dunst = {
            enable = true;
            catppuccin.enable = true;
        };
        wayland.windowManager.hyprland.settings.exec-once = ["dunst &"];
    };
}