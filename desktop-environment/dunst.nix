{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
        wayland.windowManager.hyprland.settings.exec-once = ["dunst &"];
        services.dunst = {
            enable = true;
            catppuccin.enable = false; # using our own values as overriding background breaks opacity
            settings = {
                # https://dunst-project.org/documentation/
                global = {
                    width = 400;
                    font = "Monospace 12";
                    line_height = 4;
                    padding = 12;
                    horizontal_padding = 12;
                    follow = "mouse";
                    origin = "bottom-center";
                    enable_recursive_icon_lookup = true;
                    dmenu = "bemenu -p dunst";
                    layer = "overlay";
                    frame_width = target.window.borderSize;
                    corner_radius = target.window.rounding;
                    highlight       = "#${target.style.catppuccin.highlight.hex}";
                    separator_color = "#${target.style.catppuccin.highlight.hex}";
                };
                urgency_low = {
                    background  = "#${target.style.catppuccin.base.hex+target.window.opacity.hex}";
                    foreground  = "#${target.style.catppuccin.text.hex}";
                    frame_color = "#${target.style.catppuccin.highlight.hex}";
                };
                urgency_normal = {
                    background  = "#${target.style.catppuccin.base.hex+target.window.opacity.hex}";
                    foreground  = "#${target.style.catppuccin.text.hex}";
                    frame_color = "#${target.style.catppuccin.highlight.hex}";
                };
                urgency_high = {
                    background  = "#${target.style.catppuccin.base.hex+target.window.opacity.hex}";
                    foreground  = "#${target.style.catppuccin.text.hex}";
                    frame_color = "#${target.style.catppuccin.red.hex}";
                };
            };
        };
    };
}