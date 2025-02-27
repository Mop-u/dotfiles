{inputs, config, pkgs, lib, ... }: let
    cfg = config.sidonia;
in lib.mkIf (!cfg.graphics.headless) {
    home-manager.users.${cfg.userName} = {
        catppuccin.dunst.enable = false; # using our own values as overriding background breaks opacity
        services.dunst = {
            enable = true;
            settings = let
                theme = cfg.style.catppuccin;
                rounding = builtins.toString cfg.window.rounding;
                borderSize = builtins.toString cfg.window.borderSize;
                opacity = cfg.window.opacity.hex;
            in {
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
                    frame_width = borderSize;
                    corner_radius = rounding;
                    highlight       = "#${theme.highlight.hex}";
                    separator_color = "#${theme.highlight.hex}";
                };
                urgency_low = {
                    background  = "#${theme.base.hex+opacity}";
                    foreground  = "#${theme.text.hex}";
                    frame_color = "#${theme.highlight.hex}";
                };
                urgency_normal = {
                    background  = "#${theme.base.hex+opacity}";
                    foreground  = "#${theme.text.hex}";
                    frame_color = "#${theme.highlight.hex}";
                };
                urgency_high = {
                    background  = "#${theme.base.hex+opacity}";
                    foreground  = "#${theme.text.hex}";
                    frame_color = "#${theme.red.hex}";
                };
            };
        };
    };
}