{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.sidonia;
  inherit (config.wayland.desktopManager.sidonia) window;
in
lib.mkIf (cfg.desktop.enable && (cfg.desktop.compositor == "niri")) {
  home.packages = [
    pkgs.xwayland-satellite-unstable
    pkgs.wl-clipboard
  ];
  wayland.windowManager.niri = {
    enable = true;
    package = osConfig.programs.niri.package;
    settings = lib.mkMerge [
      {
        # see: https://codeberg.org/BANanaD3V/niri-nix/src/branch/main/home-options.md
        environment = builtins.mapAttrs (n: v: lib.mkDefault v) {
          CLUTTER_BACKEND = "wayland";
          ELECTRON_ENABLE_WAYLAND = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
          ELM_DISPLAY = "wl";
          MOZ_DBUS_REMOTE = "1";
          MOZ_DISABLE_RDD_SANDBOX = "1";
          MOZ_ENABLE_WAYLAND = "1";
          NIXOS_OZONE_WL = "1";
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_ENABLE_HIGHDPI_SCALING = "1";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          SDL_VIDEODRIVER = "wayland,x11";
          SDL_VIDEO_DRIVER = "wayland,x11";
          _JAVA_AWT_WM_NONREPARENTING = "1";
        };
        cursor = {
          hide-when-typing = [ ];
          hide-after-inactive-ms = lib.mkDefault 5000;
          xcursor-size = config.home.pointerCursor.size;
        };

        input = {
          warp-mouse-to-focus._props.mode = lib.mkDefault "center-xy";
        };

        xwayland-satellite.path = lib.mkDefault (lib.getExe pkgs.xwayland-satellite-unstable);

        prefer-no-csd = [ ];
        window-rule = [
          {
            open-fullscreen = false;
            shadow.off = [ ];
            draw-border-with-background = false;
            opacity = 1.;
            geometry-corner-radius = window.decoration.rounding;
          }
          {
            match._props.is-focused = false;
            opacity = window.decoration.opacity.dec;
          }
        ];
        layer-rule = [ { shadow.off = [ ]; } ];
        layout = {
          always-center-single-column = [ ];
          shadow.off = [ ];
          focus-ring = {
            on = [ ];
            width = lib.mkDefault window.decoration.borderWidth;
          };
          border = {
            off = [ ];
            width = lib.mkDefault window.decoration.borderWidth;
          };
          default-column-width.proportion = lib.mkDefault 0.5;
          preset-column-widths._children = [
            { proportion = 1. / 3.; }
            { proportion = 1. / 2.; }
            { proportion = 2. / 3.; }
            { proportion = 1.; }
          ];
        };
        overview.workspace-shadow.off = [ ];
        hotkey-overlay.skip-at-startup = [ ];
        gestures.hot-corners.off = [ ];
      }
      (lib.mkIf (!cfg.graphics.legacyGpu) {
        window-rule = [
          {
            background-effect.blur = true;
            popups.background-effect.xray = false;
          }
          {
            match._props.is-floating = true;
            background-effect.xray = false;
          }
        ];
      })
    ];
  };
}
