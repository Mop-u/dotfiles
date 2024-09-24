{inputs, config, pkgs, lib, target, ... }:
{
    services.goxlr-utility.enable = true;
    home-manager.users.${target.userName}.wayland.windowManager.hyprland = {
        settings.exec-once = [
            "goxlr-daemon &"
        ];
    };
}
