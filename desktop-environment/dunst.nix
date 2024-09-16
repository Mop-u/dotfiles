{inputs, config, pkgs, lib, target, ... }:
{
    services.dunst = {
        enable = true;
        catppuccin.enable = true;
    };
    wayland.windowManager.hyprland.settings.exec-once = ["dunst &"];
}