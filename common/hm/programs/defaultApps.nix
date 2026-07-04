{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.sidonia;
in
lib.mkMerge [
  (lib.mkIf cfg.desktop.enable {
    programs = {
      discord.enable = lib.mkDefault true;
      vesktop.enable = lib.mkDefault true;
      obs-studio = {
        enable = lib.mkDefault true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
        ];
      };
    };
    home.packages =
      with pkgs;
      [
        # GUI apps
        pinta # Paint.NET-like image editor
        proton-vpn
        slack
        prismlauncher
        plexamp
        tageditor
      ]
      ++ (lib.optional config.services.shikane.enable config.services.shikane.package);
  })
  {
    catppuccin.cache.enable = lib.mkDefault true;
    programs = {
      btop.enable = lib.mkDefault true;
      lazygit.enable = lib.mkDefault true;
      neovim = {
        enable = lib.mkDefault true;
        defaultEditor = lib.mkDefault false;
        withPython3 = false;
        withRuby = false;
      };
      bat = {
        enable = lib.mkDefault true;
        config = {
          style = "plain";
          paging = "never";
        };
      };
    };
  }
]
