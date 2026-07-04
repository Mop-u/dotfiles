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
  home.packages = [ pkgs.mission-center ];
  wayland.desktopManager.sidonia.keybinds = [
    {
      name = "Task Manager";
      mod = [
        "super"
        "shift"
      ];
      key = "escape";
      exec = "missioncenter";
    }
  ];
}
