{inputs, config, pkgs, lib, ... }: let
    cfg = config.sidonia;
in {
    options.sidonia.programs.vesktop.enable = with lib; mkOption {
        description = "Enable Vesktop, A custom Discord App aiming to give you better performance and improve linux support";
        type = types.bool;
        default = cfg.graphics.enable;
    };
    config = lib.mkIf (cfg.programs.vesktop.enable) {
        home-manager.users.${cfg.userName} = {
            home.packages = [
                pkgs.vesktop
            ];

            home.file.vesktop = {
                enable = true;
                executable = false;
                target = "/home/${cfg.userName}/.config/vesktop/settings/quickCss.css";
                text = ''
                    @import url("https://catppuccin.github.io/discord/dist/catppuccin-${cfg.style.catppuccin.flavor}.theme.css");
                    @import url("https://catppuccin.github.io/discord/dist/catppuccin-${cfg.style.catppuccin.flavor}-${cfg.style.catppuccin.accent}.theme.css");
                '';
            };
        };
    };
}