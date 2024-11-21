{inputs, config, pkgs, lib, target, ... }: let
    withVencord = true;
in {
    home-manager.users.${target.userName} = {
        home.packages = [
            (pkgs.discord.override {
                withOpenASAR = true;
                withVencord = withVencord;
            })
        ];

        home.file.vencord = {
            enable = withVencord;
            executable = false;
            target = "/home/${target.userName}/.config/Vencord/settings/quickCss.css";
            text = ''
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${target.style.catppuccin.flavor}.theme.css");
                @import url("https://catppuccin.github.io/discord/dist/catppuccin-${target.style.catppuccin.flavor}-${target.style.catppuccin.accent}.theme.css");
            '';
        };
    };
}