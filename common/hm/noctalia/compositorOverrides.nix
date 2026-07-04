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
    wayland.desktopManager.sidonia.window.decoration.rounding = 20;
    wayland.windowManager.niri.settings = {
      window-rule = [
        { clip-to-geometry = true; }
        {
          match._props.app-id = "dev.noctalia.Noctalia.Settings";
          open-floating = true;
          default-column-width.fixed = 1080;
          default-window-height.fixed = 920;
        }
      ];
      layer-rule = [
        {
          match._props.namespace._raw = ''r#"^noctalia-backdrop"#'';
          place-within-backdrop = true;
        }
        (lib.mkIf (!cfg.graphics.legacyGpu) {
          match._props.namespace._raw = ''r#"^noctalia-(bar-main|notification|dock|panel)$"#'';
          background-effect.xray = false;
        })
      ];
      debug.honor-xdg-activation-with-invalid-serial = [ ];
    };
  }
