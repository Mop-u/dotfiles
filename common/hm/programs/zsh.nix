{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zsh.enable = lib.mkDefault true;
  programs.zoxide.enable = lib.mkDefault true;
  programs.oh-my-posh.enable = lib.mkDefault true;

  programs.zsh.syntaxHighlighting = {
    enable = lib.mkDefault true;
    highlighters = [
      "main"
      "brackets"
    ];
  };

  programs.oh-my-posh.settings =
    let
      palette = lib.mapAttrs (n: v: "#${v}") config.catppuccin.lib.color;
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
}
