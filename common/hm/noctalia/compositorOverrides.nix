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
lib.mkIf
  (cfg.desktop.enable && (cfg.desktop.compositor == "niri") && (cfg.desktop.shell == "noctalia"))
  {
    # https://docs.noctalia.dev/v5/compositor-settings/niri/
    wayland.desktopManager.sidonia.window.decoration.rounding = 20;
    wayland.windowManager.niri.settings = {
      window-rule = [
        { clip-to-geometry = true; }
        {
          match._props.app-id = "dev.noctalia.Noctalia";
          open-floating = true;
          default-column-width.fixed = 1080;
          default-window-height.fixed = 920;
        }
      ];
      layer-rule = [
        {
          match._props.namespace = "^noctalia-backdrop";
          place-within-backdrop = true;
        }
      ]
      ++ (lib.optionals (!cfg.graphics.legacyGpu) [
        {
          match._props.namespace._raw = ''"^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"'';
          background-effect.xray = false;
        }
        {
          match._props.namespace = "noctalia-window-switcher";
          background-effect = {
            blur = true;
            xray = false;
          };
        }
      ]);
      debug.honor-xdg-activation-with-invalid-serial = [ ];
    };
  }
