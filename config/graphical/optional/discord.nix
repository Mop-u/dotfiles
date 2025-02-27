{inputs, config, pkgs, lib, ... }: let
    withVencord = true;
    cfg = config.sidonia;
in lib.mkIf (!cfg.graphics.headless) {
    home-manager.users.${config.sidonia.userName} = {
        home.packages = [
            (pkgs.discord.override {
                withOpenASAR = true;
                withVencord = withVencord;
            })
        ];

        home.file.vencord = {
            enable = withVencord;
            executable = false;
            target = "/home/${config.sidonia.userName}/.config/Vencord/settings/quickCss.css";
            text = ''
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${config.sidonia.style.catppuccin.flavor}.theme.css");
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${config.sidonia.style.catppuccin.flavor}-${config.sidonia.style.catppuccin.accent}.theme.css");
            '';
        };
    };
}