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
  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "foot.desktop" ];
  };
  dconf.settings = {
    "org/cinnamon/desktop/applications/terminal" = {
      exec = lib.gvariant.mkValue (lib.getExe pkgs.foot);
      exec-arg = lib.gvariant.mkValue "-e";
    };
    "org/gnome/desktop/applications/terminal" = {
      exec = lib.gvariant.mkValue (lib.getExe pkgs.foot);
      exec-arg = lib.gvariant.mkValue "-e";
    };
  };
  programs.foot = {
    enable = true;
    settings = {
      # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
      main.dpi-aware = "no";
      main.font = "monospace:size=10";
      main.pad = "6x6 center-when-maximized-and-fullscreen";
      colors-dark.alpha = toString config.wayland.desktopManager.sidonia.window.decoration.opacity.dec;
    };
  };
  wayland.desktopManager.sidonia.keybinds = [
    {
      name = "Terminal";
      mod = [
        "super"
        "shift"
      ];
      key = "return";
      exec = "foot";
    }
  ];
}
