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

lib.mkIf (cfg.desktop.enable) (
  lib.mkMerge [
    {
      catppuccin.cursors.enable = lib.mkDefault config.catppuccin.enable;
      home.pointerCursor = {
        enable = lib.mkDefault config.catppuccin.enable;
        size = lib.mkDefault 30;
        gtk.enable = true;
        x11.enable = true;
      };
    }
  ]
)
