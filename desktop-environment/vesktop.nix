{inputs, config, pkgs, lib, target, ... }:
{
    home.packages = [
        pkgs.vesktop
    ];

    home.file.vesktop = {
        enable = true;
        executable = false;
        target = "/home/${target.userName}/.config/vesktop/settings/quickCss.css";
        text = ''
            @import url("https://catppuccin.github.io/discord/dist/catppuccin-${target.style.catppuccin.flavor}.theme.css");
            @import url("https://catppuccin.github.io/discord/dist/catppuccin-${target.style.catppuccin.flavor}-${target.style.catppuccin.accent}.theme.css");
        '';
    };
}