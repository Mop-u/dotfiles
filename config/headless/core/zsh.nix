{inputs, config, pkgs, lib, target, ... }:
{
    home-manager.users.${target.userName} = {
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
            palette = {
                os        = "p:surface2";
                closer    = "p:os";
                rosewater = "#${target.style.catppuccin.rosewater.hex}";
                flamingo  = "#${target.style.catppuccin.flamingo.hex}";
                pink      = "#${target.style.catppuccin.pink.hex}";
                mauve     = "#${target.style.catppuccin.mauve.hex}";
                red       = "#${target.style.catppuccin.red.hex}";
                maroon    = "#${target.style.catppuccin.maroon.hex}";
                peach     = "#${target.style.catppuccin.peach.hex}";
                yellow    = "#${target.style.catppuccin.yellow.hex}";
                green     = "#${target.style.catppuccin.green.hex}";
                teal      = "#${target.style.catppuccin.teal.hex}";
                sky       = "#${target.style.catppuccin.sky.hex}";
                sapphire  = "#${target.style.catppuccin.sapphire.hex}";
                blue      = "#${target.style.catppuccin.blue.hex}";
                lavender  = "#${target.style.catppuccin.lavender.hex}";
                text      = "#${target.style.catppuccin.text.hex}";
                subtext1  = "#${target.style.catppuccin.subtext1.hex}";
                subtext0  = "#${target.style.catppuccin.subtext0.hex}";
                overlay2  = "#${target.style.catppuccin.overlay2.hex}";
                overlay1  = "#${target.style.catppuccin.overlay1.hex}";
                overlay0  = "#${target.style.catppuccin.overlay0.hex}";
                surface2  = "#${target.style.catppuccin.surface2.hex}";
                surface1  = "#${target.style.catppuccin.surface1.hex}";
                surface0  = "#${target.style.catppuccin.surface0.hex}";
                base      = "#${target.style.catppuccin.base.hex}";
                mantle    = "#${target.style.catppuccin.mantle.hex}";
                crust     = "#${target.style.catppuccin.crust.hex}";
            };
            blocks = [{
                alignment = "left";
                segments = [{
                    foreground = "p:os";
                    style = "plain";
                    template = "{{.Icon}} ";
                    type = "os";
                }{
                    foreground = "p:blue";
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
                    foreground = "p:closer";
                    template = "";
                    type = "text";
                }];
                type = "prompt";
            }];
            final_space = true;
            version = 2;
        };
    };
}