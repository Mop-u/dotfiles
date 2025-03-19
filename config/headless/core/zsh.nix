{
    inputs,
    config,
    pkgs,
    lib,
    ...
}:
let
    cfg = config.sidonia;
    theme = cfg.style.catppuccin;
in
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

        programs.oh-my-posh.settings =
            let
                palette = lib.mapAttrs (n: v: "#${v.hex}") theme.color;
            in
            with palette;
            {
                # builtins.toJSON
                "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
                properties = {
                    upgrade_notice = false;
                    auto_upgrade = false;
                };
                upgrade = {
                    notice = false;
                    auto = false;
                };
                inherit palette;
                blocks = [
                    {
                        type = "prompt";
                        alignment = "left";
                        segments = [
                            {
                                foreground = accent;
                                style = "plain";
                                template = "{{ .UserName }}@{{ .HostName }} ";
                                type = "session";
                            }
                            {
                                foreground = pink;
                                properties = {
                                    folder_icon = " ";
                                    home_icon = "~";
                                    style = "agnoster_short";
                                    max_depth = 4;
                                };
                                style = "plain";
                                template = "{{ .Path }} ";
                                type = "path";
                            }
                            {
                                foreground = lavender;
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
                            }
                            {
                                style = "plain";
                                foreground = accent;
                                template = "";
                                type = "text";
                            }
                        ];
                    }
                ];
                final_space = true;
                version = 2;
                accent_color = accent;
                terminal_background = base;
                enable_cursor_positioning = true;
            };
    };
}
