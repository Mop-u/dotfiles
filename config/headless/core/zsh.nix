{inputs, config, pkgs, lib, ... }:
{
    home-manager.users.${config.sidonia.userName} = {
        programs.zsh.enable = true;
        programs.zoxide.enable = true;
        programs.oh-my-posh.enable = true;

        catppuccin.bat.enable = true;
        programs.bat = {
            enable = true;
            config = {
                style = "plain";
                paging = "never";
            };
        };

        catppuccin.zsh-syntax-highlighting.enable = true;
        programs.zsh.syntaxHighlighting = {
            enable = true;
            highlighters = [
                "main"
                "brackets"
            ];
        };

        programs.oh-my-posh.settings = { # builtins.toJSON
            "$schema"= "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
            properties = {
                upgrade_notice = false;
                auto_upgrade = false;
            };
            upgrade = {
                notice = false;
                auto = false;
            };
            palette = {
                accent    = "#${config.sidonia.style.catppuccin.highlight.hex}";
                rosewater = "#${config.sidonia.style.catppuccin.rosewater.hex}";
                flamingo  = "#${config.sidonia.style.catppuccin.flamingo.hex}";
                pink      = "#${config.sidonia.style.catppuccin.pink.hex}";
                mauve     = "#${config.sidonia.style.catppuccin.mauve.hex}";
                red       = "#${config.sidonia.style.catppuccin.red.hex}";
                maroon    = "#${config.sidonia.style.catppuccin.maroon.hex}";
                peach     = "#${config.sidonia.style.catppuccin.peach.hex}";
                yellow    = "#${config.sidonia.style.catppuccin.yellow.hex}";
                green     = "#${config.sidonia.style.catppuccin.green.hex}";
                teal      = "#${config.sidonia.style.catppuccin.teal.hex}";
                sky       = "#${config.sidonia.style.catppuccin.sky.hex}";
                sapphire  = "#${config.sidonia.style.catppuccin.sapphire.hex}";
                blue      = "#${config.sidonia.style.catppuccin.blue.hex}";
                lavender  = "#${config.sidonia.style.catppuccin.lavender.hex}";
                text      = "#${config.sidonia.style.catppuccin.text.hex}";
                subtext1  = "#${config.sidonia.style.catppuccin.subtext1.hex}";
                subtext0  = "#${config.sidonia.style.catppuccin.subtext0.hex}";
                overlay2  = "#${config.sidonia.style.catppuccin.overlay2.hex}";
                overlay1  = "#${config.sidonia.style.catppuccin.overlay1.hex}";
                overlay0  = "#${config.sidonia.style.catppuccin.overlay0.hex}";
                surface2  = "#${config.sidonia.style.catppuccin.surface2.hex}";
                surface1  = "#${config.sidonia.style.catppuccin.surface1.hex}";
                surface0  = "#${config.sidonia.style.catppuccin.surface0.hex}";
                base      = "#${config.sidonia.style.catppuccin.base.hex}";
                mantle    = "#${config.sidonia.style.catppuccin.mantle.hex}";
                crust     = "#${config.sidonia.style.catppuccin.crust.hex}";
            };
            blocks = [{
                type = "prompt";
                alignment = "left";
                segments = [{
                    foreground = "p:accent";
                    style = "plain";
                    template = "{{ .UserName }}@{{ .HostName }} ";
                    type = "session";
                }{
                    foreground = "p:pink";
                    properties = {
                        folder_icon = " ";
                        home_icon = "~";
                        style = "agnoster_short";
                        max_depth = 4;
                    };
                    style = "plain";
                    template = "{{ .Path }} ";
                    type = "path";
                }{
                    foreground = "p:lavender";
                    properties = {
                        branch_icon = " ";
                        cherry_pick_icon = " ";
                        commit_icon = " ";
                        fetch_status = false;
                        fetch_upstream_icon = false;
                        merge_icon = " ";
                        no_commits_icon = " ";
                        rebase_icon = " ";
                        revert_icon = " ";
                        tag_icon = " ";
                    };
                    template = "{{ .HEAD }} ";
                    style = "plain";
                    type = "git";
                }{
                    style = "plain";
                    foreground = "p:accent";
                    template = "";
                    type = "text";
                }];
            }];
            final_space = true;
            version = 2;
            accent_color = "p:accent";
            terminal_background = "p:base";
            enable_cursor_positioning = true;
        };
    };
}