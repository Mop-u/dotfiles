{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        programs.foot = {
            enable = true;
            catppuccin.enable = true;
            settings = {
                # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
                main.dpi-aware = "yes";
                main.font = "monospace:size=${if target.text.smallTermFont then "7" else "8"}";
                colors.alpha = builtins.toString target.window.opacity.dec;
            };
        };
        wayland.windowManager.hyprland.settings = {
            windowrulev2 = [
                "float,                           class:(foot), title:(foot)"
                "size ${target.window.float.wh},  class:(foot), title:(foot)"
                "${target.window.float.onCursor}, class:(foot), title:(foot)"
            ];
            bind = [
                "SUPERSHIFT, Return, exec, foot"
            ];
        };
    };
}