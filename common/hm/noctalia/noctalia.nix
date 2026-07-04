{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.sidonia;
  opacity = config.wayland.desktopManager.sidonia.window.decoration.opacity.dec;
in
lib.mkIf (cfg.desktop.enable && (cfg.desktop.shell == "noctalia")) {
  programs.noctalia = {
    enable = true;
    systemd.enable = lib.mkDefault true;
    settings = {
      weather = lib.mapAttrs (n: v: lib.mkDefault v) {
        enabled = cfg.geolocation.enable;
        unit = "celsius";
      };
      location = lib.mapAttrs (n: v: lib.mkDefault v) {
        auto_locate = cfg.geolocation.enable;
      };
      shell = lib.mapAttrs (n: v: lib.mkDefault v) {
        offline_mode = false;
        launch_apps_as_systemd_services = true;
        telemetry_enabled = false;
        polkit_agent = true;
        animation.enabled = (!cfg.graphics.legacyGpu);
        panel.background_blur = (!cfg.graphics.legacyGpu);
        font_family = "monospace";
        shadow.blur = 0;
      };
      notification = lib.mapAttrs (n: v: lib.mkDefault v) {
        enable_daemon = true;
        background_opacity = opacity;
      };
      brightness.enable_ddcutil = lib.mkDefault true;
      wallpaper = {
        enabled = lib.mkDefault true;
        fill_mode = lib.mkDefault "crop";
        transition = [ "fade" ];
        directory = lib.mkDefault "${config.home.homeDirectory}/Pictures/Wallpapers";
        automation = lib.mapAttrs (n: v: lib.mkDefault v) {
          enabled = true;
          order = "random";
          interval_minutes = 15;
        };
      };
      backdrop.enabled = lib.mkDefault (!cfg.graphics.legacyGpu);
      dock = lib.mapAttrs (n: v: lib.mkDefault v) {
        enabled = false;
        shadow = false;
      };
      widget.control-center = {
        custom_image = "${config.programs.noctalia.package}/share/noctalia/assets/images/distros/nixos.svg";
        custom_image_colorize = true;
      };
      bar = {
        order = [ "main" ];
        main = lib.mapAttrs (n: v: lib.mkDefault v) {
          shadow = false;
          position = "top";
          enabled = true;
          auto_hide = false;
          reserve_space = true;
          background_opacity = opacity;
          margin_ends = 16;
          margin_edge = 8;
          widget_spacing = 8;
          capsule = true;
          start = [
            "control-center"
            "notifications"
            "clock"
            "taskbar"
          ];
          center = [
            "active_window"
          ];
          end = [
            "volume"
            "network"
            "bluetooth"
            "brightness"
            "battery"
            "tray"
            "keyboard_layout"
          ];
        };
      };
    };
  };
}
