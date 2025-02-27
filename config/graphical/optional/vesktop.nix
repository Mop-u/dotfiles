{inputs, config, pkgs, lib, ... }: let
    cfg = config.sidonia;
in lib.mkIf (!cfg.graphics.headless) {
    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            pkgs.vesktop
        ];

        home.file.vesktop = {
            enable = true;
            executable = false;
            target = "/home/${config.sidonia.userName}/.config/vesktop/settings/quickCss.css";
            text = ''
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${config.sidonia.style.catppuccin.flavor}.theme.css");
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${config.sidonia.style.catppuccin.flavor}-${config.sidonia.style.catppuccin.accent}.theme.css");
            '';
        };
    };
}