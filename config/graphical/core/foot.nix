{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
in
lib.mkIf (cfg.graphics.enable) {
    home-manager.users.${config.sidonia.userName} = {
        catppuccin.foot.enable = true;
        programs.foot = {
            enable = true;
            settings = {
                # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
                main.dpi-aware = "yes";
                main.font = "monospace:size=${if cfg.text.smallTermFont then "6" else "7"}";
                colors.alpha = builtins.toString cfg.window.opacity.dec;
            };
        };
        wayland.windowManager.hyprland.settings = {
            windowrulev2 = [
                "float,                        class:(foot), title:(foot)"
                "size ${cfg.window.float.wh},  class:(foot), title:(foot)"
                "${cfg.window.float.onCursor}, class:(foot), title:(foot)"
            ];
            bind = [
                "SUPERSHIFT, Return, exec, foot"
            ];
        };
    };
}
