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
lib.mkIf (cfg.desktop.enable) {
  home.packages = with pkgs; [
    # Hyprland / core apps
    qimgv
    mpv # video player
    dconf-editor # view gsettings stuff
    gsettings-desktop-schemas
    ungoogled-chromium
  ];
}
